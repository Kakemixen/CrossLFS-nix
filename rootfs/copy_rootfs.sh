file=$1
target=$(readlink $1)
dstdir=$2

dst_path () {
	local path
	path=$1
	local path_no_store
	path_no_store=${path/#\/nix\/store\//}
	local path_no_nothing
	path_no_nothing="${path_no_store#*/}"

	curr_dir_path="${dstdir}/$(dirname $path_no_nothing)"
	curr_dst_path="${dstdir}/$path_no_nothing"
}

if [[ "/nix/store" == ${target:0:10} ]]; then
	dst_path $file
	rm -f $curr_dst_path
	if [ -d $target ]; then
		echo "found dir: $file -> $(readlink $file)"

		echo "mkdir -p $curr_dir_path"
		mkdir -p $curr_dst_path

		echo "cp -r $file/ $curr_dst_path/"
		cp -r $file/* $curr_dst_path/

		# recurse!
		$0 $curr_dst_path $2
	else
		echo "found file: $file -> $(readlink $file)"

		echo "mkdir -p $curr_dir_path"
		mkdir -p $curr_dir_path

		echo "cp -L $file $curr_dst_path"
		cp -L $file $curr_dst_path
	fi
fi
