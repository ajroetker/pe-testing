#!/usr/bin/env bash

set -e

while getopts cfbn name; do
    case "$name" in
        c)
            PE_PLATFORM=${PE_PLATFORM:-'el-6-x86_64'}
            ;;
        f)
            force_fetch='y'
            ;;
        b)
            build_only='y'
            ;;
        n)
            download_latest='n'
            ;;
        ?)
            ;;
    esac
done

init() {
    pe_testing="$( dirname "${BASH_SOURCE[0]}" )/.."
    enterprise_dist="${pe_testing}/../enterprise-dist"
    pe_module="${pe_testing}/../puppetlabs-puppet_enterprise"
    version=${PE_VERSION:-'3.4'}
    current_version=$(basename "$(readlink puppet-enterprise)")
    if [ "${build_only}" != 'y' ]; then
        target_version=${PE_TAG:-$(curl --silent neptune.puppetlabs.lan/${version}/ci-ready/LATEST)}
        target_platform=${PE_PLATFORM:-'debian-7-amd64'}

        target="${target_version?}-${target_platform?}"
    else
        target="${current_version}"
    fi
}


log() {
    echo "[ INFO ] ${1?}"
}

fetch_latest() {
    log "Fetching ${target_version?} for ${target_platform?}"
    rm -f "${pe_testing}/tarballs/puppet-enterprise-${target?}.tar"
    curl neptune.puppetlabs.lan/${version}/ci-ready/puppet-enterprise-${target?}.tar -o "${pe_testing}/tarballs/puppet-enterprise-${target?}.tar"
}

unpack_tarball() {
    log "Unpacking tarball to ${pe_testing}/${target?}"
    tar xf "${pe_testing}/tarballs/puppet-enterprise-${target?}.tar" -C "${pe_testing}/versions"
    rm -rf "${pe_testing}/tarballs/puppet-enterprise-${target?}.tar"

    rm -rf "${pe_testing}/versions/${target?}"
    mv "${pe_testing}/versions/puppet-enterprise-${target?}" "${pe_testing}/versions/${target?}"
}

make_version_repo() {
    git init "${pe_testing}/versions/${target?}" && git -C "${pe_testing}/versions/${target?}" commit --allow-empty -m 'Initial commit'
    add_and_commit_changes 'Unpacked tarball'
}

add_and_commit_changes() {
    git -C "${pe_testing}/versions/${target?}" add .
    git -C "${pe_testing}/versions/${target?}" commit -m "${1?}" --all --allow-empty
}

make_headless_changes() {
    # sometimes this gets left over between runs
    rm -f ${pe_testing}/versions/${target?}/answers.lastrun.*
    log "Checking out to headless branch; discarding any previous existing changes"
    git -C "${pe_testing}/versions/${target?}" checkout $(git -C "${pe_testing}/versions/${target?}" rev-parse master) > /dev/null
    #copy everything in the installer directory we need
    installer_dir="${enterprise_dist}/installer"
    log "Copying enterprise-dist files"
    for file in "puppet-enterprise-installer" "puppet-enterprise-uninstaller" "utilities" "db_import_export.rake" "pe-classification.rb" "update-superuser-password.rb"; do
        cp "${installer_dir}/${file}" "${pe_testing}/versions/${target?}"
    done
    #copy everything else
    for file in "puppet-enterprise-support" "modules" "ext/erb"; do
        cp -r "${enterprise_dist}/${file}" "${pe_testing}/versions/${target?}"
    done
    add_and_commit_changes 'Copied from enterprise-dist'

    export BUNDLE_GEMFILE="${pe_testing?}/Gemfile"
    bundle exec puppet module build "${pe_module}"
    log "Copying puppetlabs-puppet_enterprise module"
    cp -r ${pe_module}/pkg/*.tar.gz ${pe_testing}/versions/${target?}/modules/puppetlabs-puppet_enterprise-*.tar.gz
    add_and_commit_changes 'Copied puppetlabs-puppet_enterprise'
}

init

if [ "${build_only}" != 'y' ]; then
    if [ "${download_latest}" != 'n' ] && [ ! -e "${pe_testing}/versions/${target?}" -o "${force_fetch}" == 'y' ]; then
        fetch_latest
        unpack_tarball
        make_version_repo
        pushd "${pe_testing}" &> /dev/null
        rm -f puppet-enterprise
        ln -s versions/$target puppet-enterprise
        log "Linked ${target?}"
        popd &> /dev/null
    fi
fi

make_headless_changes
