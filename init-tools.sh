restore_nuget()
{
  # Check for existence of curl or wget
   which curl wget > /dev/null 2> /dev/null
   if [ $? -ne 0 -a $? -ne 1 ]; then
      echo "cURL or wget is required to build. Please see https://github.com/dotnet/corefx/blob/master/Documentation/building/unix-instructions.mx for more details."
      exit 1
   fi

   which curl > /dev/null 2> /dev/null
   if [ $? -ne 0 ]; then
      mkdir -p "$__PACKAGES_DIR"
      wget -q -O $__NUGET_PATH https://api.nuget.org/downloads/nuget.exe
   else
      curl -sSL --create-dirs -o $__NUGET_PATH https://api.nuget.org/downloads/nuget.exe
   fi

   if [ $? -ne 0 ]; then
      echo "Failed to restore NuGet.exe"
      exit 1
   fi
}

clean_buildtools()
{
   echo "Cleaning BuildTools..."
   if [ -d $__PACKAGES_DIR/$__BUILD_TOOLS_PACKAGE_NAME ]; then
      rm -rf "$__PACKAGES_DIR/$__BUILD_TOOLS_PACKAGE_NAME"
   fi
   exit 0
}

check_for_mono()
{
   __monoversion=$(mono --version | grep "version 4.[1-9]")

   if [ $? -ne 0 ]; then
      # if built from tarball, mono only identifies itself as 4.0.1
      __monoversion=$(mono --version | egrep "version 4.0.[1-9]+(.[0-9]+)?")
      if [ $? -ne 0 ]; then
         echo "Mono 4.0.1.44 or later is required to build corefx. Please see https://github.com/dotnet/corefx/blob/master/Documentation/building/unix-instructions.md for more details."
         exit 1
      else
         echo "WARNING: Mono 4.0.1.44 or later is required to build corefx. Unable to assess if current version is supported."
      fi
   fi
}

__BUILD_TOOLS_PACKAGE_NAME="Microsoft.DotNet.BuildTools"
__BUILD_TOOLS_PACKAGE_VERSION="1.0.25-prerelease-00105"


__scriptpath=$(cd "$(dirname "$0")"; pwd -P)
__PROJECT_DIR=$__scriptpath
__PACKAGES_DIR=$__PROJECT_DIR/packages
__NUGET_PATH=$__PACKAGES_DIR/NuGet.exe
__BUILD_TOOLS_FEED="https://www.myget.org/F/dotnet-buildtools"


if [ "$1" == "/c" ]; then
   clean_buildtools
fi

if [ ! -e $__NUGET_PATH ]; then
   restore_nuget
fi

if [ "$1" != "" ]; then
   __BUILD_TOOLS_FEED=$1
fi

check_for_mono

mono $__NUGET_PATH install $__BUILD_TOOLS_PACKAGE_NAME -Version $__BUILD_TOOLS_PACKAGE_VERSION -Source $__BUILD_TOOLS_FEED -ExcludeVersion -o $__PACKAGES_DIR -nocache -pre

chmod +x "$__PACKAGES_DIR/$__BUILD_TOOLS_PACKAGE_NAME/init-tools.sh"

"$__PACKAGES_DIR/$__BUILD_TOOLS_PACKAGE_NAME/init-tools.sh" "$__PROJECT_DIR" "$__PACKAGES_DIR" "$__NUGET_PATH"
