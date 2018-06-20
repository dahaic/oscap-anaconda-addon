#!/bin/bash

build_dir=$PWD

actions=(download_rpms install_rpms install_addon_from_repo create_image cleanup)


# ARG_POSITIONAL_SINGLE([start-with],[Action to start with - one of: ${actions[*]}],[install_rpms])
# ARG_OPTIONAL_SINGLE([rpm-dir],[],[Where to put/take from RPMs to install],[$build_dir/rpm])
# ARG_OPTIONAL_SINGLE([tmp-root],[],[Fake temp root],[$(mktemp -d)])
# ARG_OPTIONAL_SINGLE([releasever],[r],[Version of the target OS],[28])
# ARG_TYPE_GROUP_SET([action],[ACTION],[start-with],[download_rpms,install_rpms,install_addon_from_repo,create_image,cleanup],[index])
# ARG_HELP([])
# ARGBASH_GO()
# needed because of Argbash --> m4_ignore([
### START OF CODE GENERATED BY Argbash v2.6.1 one line above ###
# Argbash is a bash code generator used to get arguments parsing right.
# Argbash is FREE SOFTWARE, see https://argbash.io for more info

die()
{
	local _ret=$2
	test -n "$_ret" || _ret=1
	test "$_PRINT_HELP" = yes && print_help >&2
	echo "$1" >&2
	exit ${_ret}
}

begins_with_short_option()
{
	local first_option all_short_options
	all_short_options='rh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}


# validators
action()
{
	local _allowed=("download_rpms" "install_rpms" "install_addon_from_repo" "create_image" "cleanup")
	local _seeking="$1"
	local _idx=0
	for element in "${_allowed[@]}"
	do
		test "$element" = "$_seeking" && { test "$3" = "idx" && echo "$_idx" || echo "$element"; } && return 0
		_idx=$((_idx + 1))
	done
	die "Value '$_seeking' (of argument '$2') doesn't match the list of allowed values: 'download_rpms', 'install_rpms', 'install_addon_from_repo', 'create_image' and 'cleanup'" 4
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
_arg_start_with="install_rpms"
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_rpm_dir="$build_dir/rpm"
_arg_tmp_root="$(mktemp -d)"
_arg_releasever="28"

print_help ()
{
	printf 'Usage: %s [--rpm-dir <arg>] [--tmp-root <arg>] [-r|--releasever <arg>] [-h|--help] [<start-with>]\n' "$0"
	printf '\t%s\n' "<start-with>: Action to start with - one of: ${actions[*]} (default: 'install_rpms')"
	printf '\t%s\n' "--rpm-dir: Where to put/take from RPMs to install (default: '$build_dir/rpm')"
	printf '\t%s\n' "--tmp-root: Fake temp root (default: '$(mktemp -d)')"
	printf '\t%s\n' "-r,--releasever: Version of the target OS (default: '28')"
	printf '\t%s\n' "-h,--help: Prints help"
}

parse_commandline ()
{
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			--rpm-dir)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_rpm_dir="$2"
				shift
				;;
			--rpm-dir=*)
				_arg_rpm_dir="${_key##--rpm-dir=}"
				;;
			--tmp-root)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_tmp_root="$2"
				shift
				;;
			--tmp-root=*)
				_arg_tmp_root="${_key##--tmp-root=}"
				;;
			-r|--releasever)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_releasever="$2"
				shift
				;;
			--releasever=*)
				_arg_releasever="${_key##--releasever=}"
				;;
			-r*)
				_arg_releasever="${_key##-r}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			*)
				_positionals+=("$1")
				;;
		esac
		shift
	done
}


handle_passed_args_count ()
{
	test ${#_positionals[@]} -le 1 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect between 0 and 1, but got ${#_positionals[@]} (the last one was: '${_positionals[*]: -1}')." 1
}

assign_positional_args ()
{
	_positional_names=('_arg_start_with' )

	for (( ii = 0; ii < ${#_positionals[@]}; ii++))
	do
		eval "${_positional_names[ii]}=\${_positionals[ii]}" || die "Error during argument parsing, possibly an Argbash bug." 1
	done
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args

# OTHER STUFF GENERATED BY Argbash
# Validation of values
_arg_start_with="$(action "$_arg_start_with" "start-with")" || exit 1
_arg_start_with_index="$(action "$_arg_start_with" "start-with" idx)"

### END OF CODE GENERATED BY Argbash (sortof) ### ])
# [ <-- needed because of Argbash

tmp_root="$_arg_tmp_root"
rpmdir="$_arg_rpm_dir"


packages="
	openscap
	openscap-python3
	openscap-scanner
	python3-cpio
	python3-pycurl
	oscap-anaconda-addon
"


download_rpms() {
	mkdir -p "$rpmdir"
	(cd "$rpmdir" && dnf download --arch x86_64,noarch --releasever "$_arg_release" $packages)
}


install_rpms() {
	test -d "$rpmdir" || return 0  # Nothing to do, no RPM dir exists
	# Install pre-downloaded RPMs to the fake root, sudo is required
	for pkg in "$rpmdir/"*.rpm; do
		sudo rpm -i --nodeps --root "$tmp_root" "$pkg"
	done
}


install_addon_from_repo() {
	# "copy files" to new root, sudo needed because we may overwrite files installed by rpm
	sudo make install DESTDIR="${tmp_root}" >&2
}


create_image() {
	# create update image
	cd "$tmp_root"
	find -L . | cpio -oc | gzip > "$build_dir/update.img"
}


cleanup() {
	# cleanup, sudo needed because former RPM installs
	sudo rm -rf "$tmp_root"
}


sudo true || die "Unable to get sudo working, bailing out."

for (( action_index=_arg_start_with_index;  action_index < ${#actions[*]}; action_index++ )) do
	"${actions[$action_index]}"
done

# ] <-- needed because of Argbash
