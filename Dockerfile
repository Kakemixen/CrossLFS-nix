# doing CLFS to raspberry pi zero
FROM archlinux:base-devel

CMD ["/bin/bash"]
SHELL ["/bin/bash", "-c"]
RUN pacman -Syyu --noconfirm
RUN pacman -S --noconfirm wget rsync sed

ENV CLFS=/clfs
RUN mkdir -p ${CLFS}/{sources,builds,usr,cross-tools,tarballs,patches}

RUN set +h && umask 022 && unset CFLAGS && unset CXXFLAGS

ENV LC_ALL=POSIX \
    PATH=${CLFS}/cross-tools/bin:/bin:/usr/bin

#Build variables
ENV CLFS_FLOAT="hard" \
    CLFS_FPU="vfp" \
    CLFS_HOST="x86_64-cross-linux-gnu" \
    CLFS_TARGET="arm-linux-musleabihf" \
    CLFS_ARCH="arm" \
    CLFS_ENDIAN="little" \
    CLFS_ARM_ARCH="armv6zk"

#sysroot
RUN mkdir -p ${CLFS}/cross-tools/${CLFS_TARGET} && \ 
    ln -sfv . ${CLFS}/cross-tools/${CLFS_TARGET}/usr

# Cross toolchain
# binutils
ENV BINU=binutils-2.37
RUN wget -nv http://ftp.gnu.org/gnu/binutils/${BINU}.tar.xz -O ${CLFS}/tarballs/${BINU}.tar.xz
RUN tar -xaf ${CLFS}/tarballs/${BINU}.tar.xz -C ${CLFS}/sources && \
    mkdir "${CLFS}/builds/binutils-build" && \
    cd ${CLFS}/builds/binutils-build && \
    echo "configuring" && \
    ${CLFS}/sources/${BINU}/configure \
       --prefix=${CLFS}/cross-tools \
       --target=${CLFS_TARGET} \
       --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
       --disable-nls \
       --disable-multilib && \
    echo "configure-host" && \
    make configure-host && \
    echo "make" && \
    make -j 42 && \
    echo "make install" && \
    make install && \
    echo "remove source" && \
    cd && rm "${CLFS}/builds/binutils-build" -r && \
    rm "${CLFS}/sources/${BINU}" -r

# Scrt1.o is x86-64
# GCC static
ENV GCC=gcc-11.2.0
RUN wget -nv https://gcc.gnu.org/pub/gcc/releases/${GCC}/${GCC}.tar.xz -O ${CLFS}/tarballs/${GCC}.tar.xz

ENV MPFR=mpfr-4.1.0
RUN wget -nv http://ftp.gnu.org/gnu/mpfr/${MPFR}.tar.xz -O ${CLFS}/tarballs/${MPFR}.tar.xz
ENV GMP=gmp-6.2.1
RUN wget -nv http://ftp.gnu.org/gnu/gmp/${GMP}.tar.xz -O ${CLFS}/tarballs/${GMP}.tar.xz
ENV MPC=mpc-1.2.1
RUN wget -nv http://ftp.gnu.org/gnu/mpc/${MPC}.tar.gz -O ${CLFS}/tarballs/${MPC}.tar.gz
RUN tar -xaf ${CLFS}/tarballs/${GCC}.tar.xz -C ${CLFS}/sources && \
    tar -xaf ${CLFS}/tarballs/${MPFR}.tar.xz -C ${CLFS}/sources/${GCC} && \
    mv ${CLFS}/sources/${GCC}/${MPFR} ${CLFS}/sources/${GCC}/mpfr && \
    tar -xaf ${CLFS}/tarballs/${GMP}.tar.xz -C ${CLFS}/sources/${GCC} && \
    mv -v ${CLFS}/sources/${GCC}/${GMP} ${CLFS}/sources/${GCC}/gmp && \
    tar -xaf ${CLFS}/tarballs/${MPC}.tar.gz -C ${CLFS}/sources/${GCC} && \
    mv -v ${CLFS}/sources/${GCC}/${MPC} ${CLFS}/sources/${GCC}/mpc && \
    mkdir "${CLFS}/builds/gcc-build" && \
    cd ${CLFS}/builds/gcc-build && \
    echo "configuring" && \
    ${CLFS}/sources/${GCC}/configure \
        --build=${CLFS_HOST} \
        --host=${CLFS_HOST} \
        --target=${CLFS_TARGET} \
        --prefix=${CLFS}/cross-tools \
        --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
        --disable-nls \
        --disable-shared \
        --without-headers \
        --with-newlib \
        --disable-decimal-float \
        --disable-libgomp \
        --disable-libmudflap \
        --disable-libssp \
        --disable-libatomic \
        --disable-libquadmath \
        --disable-threads \
        --enable-languages=c \
        --disable-multilib \
        --with-mpfr-include=${CLFS}/sources/${GCC}/mpfr/src \
        --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
        --with-arch=${CLFS_ARM_ARCH} \
        --with-float=${CLFS_FLOAT} \
        --with-fpu=${CLFS_FPU} && \
    echo "make compile" && \
    make -j42 all-gcc all-target-libgcc && \
    echo "make install" && \
    make install-gcc install-target-libgcc && \
    echo "remove source" && \
    cd && rm "${CLFS}/builds/gcc-build" -r && \
    rm "${CLFS}/sources/${GCC}" -r

# Scrt1.0 is x86-64
# musl library
ENV MUSL=musl-1.2.2
RUN wget -nv http://www.musl-libc.org/releases/${MUSL}.tar.gz -O ${CLFS}/tarballs/${MUSL}.tar.gz
RUN tar -xaf ${CLFS}/tarballs/${MUSL}.tar.gz -C ${CLFS}/sources && \
    cd ${CLFS}/sources/${MUSL} && \
    echo "configuring" && \
    ./configure \
        CROSS_COMPILE=${CLFS_TARGET}- \
        --prefix=/ \
        --target=${CLFS_TARGET} \
        --build=${CLFS_HOST} && \
    echo "make" && \
    make -j 42 && \
	echo "make install" && \
    DESTDIR=${CLFS}/cross-tools/${CLFS_TARGET} make install && \
    echo "remove source" && \
    cd && rm "${CLFS}/sources/${MUSL}" -r

# Scrt1.0 is 32bit ARM -> fixed to x86-64
# the problem was that the && between DESTDIR and make install fucked stuff up

# GCC again
RUN tar -xaf ${CLFS}/tarballs/${GCC}.tar.xz -C ${CLFS}/sources && \
    tar -xaf ${CLFS}/tarballs/${MPFR}.tar.xz -C ${CLFS}/sources/${GCC} && \
    mv ${CLFS}/sources/${GCC}/${MPFR} ${CLFS}/sources/${GCC}/mpfr && \
    tar -xaf ${CLFS}/tarballs/${GMP}.tar.xz -C ${CLFS}/sources/${GCC} && \
    mv -v ${CLFS}/sources/${GCC}/${GMP} ${CLFS}/sources/${GCC}/gmp && \
    tar -xaf ${CLFS}/tarballs/${MPC}.tar.gz -C ${CLFS}/sources/${GCC} && \
    mv -v ${CLFS}/sources/${GCC}/${MPC} ${CLFS}/sources/${GCC}/mpc && \
    mkdir "${CLFS}/builds/gcc-build" && \
    cd ${CLFS}/builds/gcc-build && \
    echo "configuring" && \
    ${CLFS}/sources/${GCC}/configure \
	    --prefix=${CLFS}/cross-tools \
        --build=${CLFS_HOST} \
        --host=${CLFS_HOST} \
        --target=${CLFS_TARGET} \
        --with-sysroot=${CLFS}/cross-tools/${CLFS_TARGET} \
        --disable-nls \
        --enable-languages=c \
        --enable-c99 \
        --enable-long-long \
        --disable-libmudflap \
        --disable-multilib \
        --with-mpfr-include=${CLFS}/sources/${GCC}/mpfr/src \
        --with-mpfr-lib=$(pwd)/mpfr/src/.libs \
        --with-arch=${CLFS_ARM_ARCH} \
        --with-float=${CLFS_FLOAT} \
        --with-fpu=${CLFS_FPU} && \
    echo "make compile" && \
    make -j42 && \
    echo "make install" && \
    make install && \
    echo "remove source" && \
    cd && rm "${CLFS}/builds/gcc-build" -r && \
    rm "${CLFS}/sources/${GCC}" -r

# toolchain vars
ENV CC="${CLFS_TARGET}-gcc --sysroot=${CLFS}/targetfs" \
	CXX="${CLFS_TARGET}-g++ --sysroot=${CLFS}/targetfs" \
	LD="${CLFS_TARGET}-ld --sysroot=${CLFS}/targetfs" \
	AR="${CLFS_TARGET}-ar" \
	AS="${CLFS_TARGET}-as" \
	RANLIB="${CLFS_TARGET}-ranlib" \
	READELF="${CLFS_TARGET}-readelf" \
	STRIP="${CLFS_TARGET}-strip"

#filesystem
RUN mkdir -pv ${CLFS}/targetfs/{bin,boot,dev,etc,\
home,lib/{firmware,modules},mnt,opt,proc,sbin,srv,sys,\
var/{cache,lib,local,lock,log,opt,run,spool},\
usr/{,local/}{bin,include,lib,sbin,share,src}}

RUN install -dv -m 0750 ${CLFS}/targetfs/root && install -dv -m 1777 ${CLFS}/targetfs/{var/,}tmp

RUN ln -svf ../proc/mounts ${CLFS}/targetfs/etc/mtab

RUN echo "root::0:0:root:/root:/bin/bash" > ${CLFS}/targetfs/etc/passwd && \
	echo "daemon:x:2:6:daemon:/sbin:/bin/false" >> ${CLFS}/targetfs/etc/passwd && \
	echo "uup:x:32:31:uucp:/var/spool/uucp:/bin/false" >> ${CLFS}/targetfs/etc/passwd

RUN echo "root:x:0:" > ${CLFS}/targetfs/etc/group && \
	echo "bin:x:1:" >> ${CLFS}/targetfs/etc/group && \
	echo "sys:x:2:" >> ${CLFS}/targetfs/etc/group && \
	echo "kmem:x:3:" >> ${CLFS}/targetfs/etc/group && \
	echo "tty:x:4:" >> ${CLFS}/targetfs/etc/group && \
	echo "tape:x:5:" >> ${CLFS}/targetfs/etc/group && \
	echo "daemon:x:6:" >> ${CLFS}/targetfs/etc/group && \
	echo "floppy:x:7:" >> ${CLFS}/targetfs/etc/group && \
	echo "disk:x:8:" >> ${CLFS}/targetfs/etc/group && \
	echo "lp:x:9:" >> ${CLFS}/targetfs/etc/group && \
	echo "dialout:x:10:" >> ${CLFS}/targetfs/etc/group && \
	echo "audio:x:11:" >> ${CLFS}/targetfs/etc/group && \
	echo "video:x:12:" >> ${CLFS}/targetfs/etc/group && \
	echo "utmp:x:13:" >> ${CLFS}/targetfs/etc/group && \
	echo "usb:x:14:" >> ${CLFS}/targetfs/etc/group && \
	echo "cdrom:x:15:" >> ${CLFS}/targetfs/etc/group && \
	echo "uucp:x:32:uucp" >> ${CLFS}/targetfs/etc/group

RUN touch ${CLFS}/targetfs/var/log/lastlog && chmod -v 664 ${CLFS}/targetfs/var/log/lastlog

RUN cp -v ${CLFS}/cross-tools/${CLFS_TARGET}/lib/libgcc_s.so.1 ${CLFS}/targetfs/lib/ && \
	${STRIP} ${CLFS}/targetfs/lib/libgcc_s.so.1

# musl to system
RUN tar -xaf ${CLFS}/tarballs/${MUSL}.tar.gz -C ${CLFS}/sources && \
    cd ${CLFS}/sources/${MUSL} && \
    echo "configuring" && \
    ./configure \
        CROSS_COMPILE=${CLFS_TARGET}- \
        --prefix=/ \
        --target=${CLFS_TARGET} \
		--disable-static && \
    echo "make" && \
    make -j 42 && \
	echo "make install" && \
    DESTDIR=${CLFS}/targetfs make install-libs && \
    echo "remove source" && \
    cd && rm "${CLFS}/sources/${MUSL}" -r

# linux header files
ENV LINUX_SHA=42e3206162247e3848aef22e7a384ea60f3ebb5c
ENV LINUX=linux-${LINUX_SHA}
RUN wget -nv https://github.com/raspberrypi/linux/archive/${LINUX_SHA}.tar.gz  -O ${CLFS}/tarballs/${LINUX}.tar.gz
#RUN wget -nv https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/${LINUX}.tar.xz -O ${CLFS}/tarballs/${LINUX}.tar.xz
RUN tar -xaf ${CLFS}/tarballs/${LINUX}.tar.gz -C ${CLFS}/sources && \
    cd ${CLFS}/sources/${LINUX} && \
    echo "make mrproper" && \
    make mrproper && \
    echo "install headers" && \
    make ARCH=${CLFS_ARCH} INSTALL_HDR_PATH=${CLFS}/cross-tools/${CLFS_TARGET} headers_install && \
    echo "remove source" && \
    cd && rm ${CLFS}/sources/${LINUX} -r

# busybox to system
ENV BBOX=busybox-1.34.1
RUN wget -nv http://busybox.net/downloads/${BBOX}.tar.bz2 -O ${CLFS}/tarballs/${BBOX}.tar.bz2
RUN tar -xaf ${CLFS}/tarballs/${BBOX}.tar.bz2 -C ${CLFS}/sources && \
	cd ${CLFS}/sources/${BBOX} && \
	echo "cleaning" && \
	make distclean && \
	echo "making defconfig" && \
	make ARCH="${CLFS_ARCH}" -j42 defconfig && \
	echo "sedding" && \
	sed -i 's/\(CONFIG_\)\(.*\)\(INETD\)\(.*\)=y/# \1\2\3\4 is not set/g' .config && \
	sed -i 's/\(CONFIG_IFPLUGD\)=y/# \1 is not set/' .config && \
	sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' .config && \
	sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' .config && \
	sed -i 's/\(CONFIG_FEATURE_WTMP\)=y/# \1 is not set/' .config && \
	sed -i 's/\(CONFIG_FEATURE_UTMP\)=y/# \1 is not set/' .config && \
	echo "making for real" && \
	make ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" -j42 && \
	make ARCH="${CLFS_ARCH}" CROSS_COMPILE="${CLFS_TARGET}-" CONFIG_PREFIX="${CLFS}/targetfs" install && \
	echo "getting depmod" && \
	cp -v examples/depmod.pl ${CLFS}/cross-tools/bin && \
	chmod -v 755 ${CLFS}/cross-tools/bin/depmod.pl && \
    echo "remove source" && \
    cd && rm "${CLFS}/sources/${BBOX}" -r

#fstab
RUN echo "file-system	mount-point	type	options	dump	fsck" > ${CLFS}/targetfs/etc/fstab

RUN pacman -S --noconfirm bc

# linux kernel
RUN tar -xaf ${CLFS}/tarballs/${LINUX}.tar.gz -C ${CLFS}/sources && \
    cd ${CLFS}/sources/${LINUX} && \
    echo "make mrproper" && \
    make mrproper && \
    echo "make config" && \
    make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- bcm2709_defconfig && \
    echo "make kernel" && \
    make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -j42 zImage && \
	echo "installing" && \
    INSTALL_PATH=${CLFS}/targetfs/boot \
		make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- install && \
	cp arch/arm/boot/*Image ${CLFS}/targetfs/boot && \
	echo "install modules" && \
    make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -j42 modules && \
    make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -j42 \
		INSTALL_MOD_PATH=${CLFS}/targetfs modules_install && \
	echo "install device tree" && \
    make ARCH=${CLFS_ARCH} CROSS_COMPILE=${CLFS_TARGET}- -j42 dtbs && \
	cp -r arch/arm/boot/dts/* ${CLFS}/targetfs/boot && \
    echo "remove source" && \
    cd && rm ${CLFS}/sources/${LINUX} -r


# files
RUN mkdir -pv ${CLFS}/targetfs/etc/network/if-{post-{up,down},pre-{up,down},up,down}.d && \
	mkdir -pv ${CLFS}/targetfs/usr/share/udhcpc
ADD files /files
RUN echo "lfs-pi" > ${CLFS}/targetfs/etc/HOSTNAME

# ownership - just to be sure
RUN chown -R root:root ${CLFS}/targetfs && \
	chgrp -v 13 ${CLFS}/targetfs/var/log/lastlog

# create the output tarball
RUN install -dv ${CLFS}/out && \
	cd ${CLFS}/targetfs && \
	tar jcfv ${CLFS}/out/clfs-arm.tar.bz2 *
