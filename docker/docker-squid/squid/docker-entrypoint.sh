#! /bin/sh
set -e



# http://www.squid-cache.org/Doc/config/cache_effective_user
SQUID_EFFECTIVE_USER=${SQUID_EFFECTIVE_USER:-squid}

# http://www.squid-cache.org/Doc/config/cache_effective_group
SQUID_EFFECTIVE_GROUP=${SQUID_EFFECTIVE_GROUP:-squid}


# http://www.squid-cache.org/Doc/config/cache_mem/
SQUID_CACHE_MEM=${SQUID_CACHE_MEM:-256}


# http://www.squid-cache.org/Doc/config/maximum_object_size_in_memory/
SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY=${SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY:-512}

# http://www.squid-cache.org/Doc/config/memory_replacement_policy/
SQUID_MEMORY_REPLACEMENT_POLICY=${SQUID_MEMORY_REPLACEMENT_POLICY:-heap GDSF}


# http://www.squid-cache.org/Doc/config/cache_dir/
SQUID_CACHE_DIR=${SQUID_CACHE_DIR:-/var/cache/squid}
SQUID_CACHE_SIZE=${SQUID_CACHE_SIZE:-100}

# http://www.squid-cache.org/Doc/config/maximum_object_size/
SQUID_MAXIMUM_OBJECT_SIZE=${SQUID_MAXIMUM_OBJECT_SIZE:-16}

# http://www.squid-cache.org/Doc/config/cache_replacement_policy/
SQUID_CACHE_REPLACEMENT_POLICY=${SQUID_CACHE_REPLACEMENT_POLICY:-heap LFUDA}


# network CIDR default settings
SQUID_NET_CIDR=${SQUID_NET_CIDR:-24} 


apply_cache_effective_user_group()
{
    grep  '^cache_effective_user' /etc/squid/squid.conf \
    || echo "cache_effective_user ${SQUID_EFFECTIVE_USER}" >> /etc/squid/squid.conf
    grep  '^cache_effective_group' /etc/squid/squid.conf \
    || echo "cache_effective_group ${SQUID_EFFECTIVE_GROUP}" >> /etc/squid/squid.conf

}

apply_cache_mem()
{
    grep  '^cache_mem' /etc/squid/squid.conf \
    || echo "cache_mem ${SQUID_CACHE_MEM} MB" >> /etc/squid/squid.conf
}

apply_maximum_object_size_in_memory()
{
    grep  '^maximum_object_size_in_memory' /etc/squid/squid.conf \
    || echo "maximum_object_size_in_memory ${SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY} KB" >> /etc/squid/squid.conf
}


apply_memory_replacement_policy()
{
    grep  '^memory_replacement_policy' /etc/squid/squid.conf \
    || echo "memory_replacement_policy ${SQUID_MEMORY_REPLACEMENT_POLICY}" >> /etc/squid/squid.conf
}

apply_cache_dir()
{
    grep  '^cache_dir' /etc/squid/squid.conf \
    || echo "cache_dir aufs ${SQUID_CACHE_DIR} ${SQUID_CACHE_SIZE} 16 256" >> /etc/squid/squid.conf

    if [ ! -d ${SQUID_CACHE_DIR}/00 ]; then

	echo "Initializing cache..."
	chown -R ${SQUID_EFFECTIVE_USER}:${SQUID_EFFECTIVE_GROUP} ${SQUID_CACHE_DIR}
	/usr/sbin/squid -Nz -f /etc/squid/squid.conf
    fi
}

apply_maximum_object_size()
{
    grep  '^maximum_object_size' /etc/squid/squid.conf \
    || echo "maximum_object_size ${SQUID_MAXIMUM_OBJECT_SIZE} MB" >> /etc/squid/squid.conf
}

apply_cache_replacement_policy()
{
    grep  '^cache_replacement_policy' /etc/squid/squid.conf \
    || echo "cache_replacement_policy ${SQUID_CACHE_REPLACEMENT_POLICY}" >> /etc/squid/squid.conf
}

apply_user_network_cidr()
{
    # optional
    if [ ! -z ${SQUID_NET+x} ]; then
	grep '^acl SQUID_NET src' /etc/squid/squid.conf \
	|| echo "acl SQUID_NET src ${SQUID_NET}/${SQUID_NET_CIDR}" >> /etc/squid/squid.conf
	grep '^http_access allow SQUID_NET' /etc/squid/squid.conf \
	|| echo "http_access allow SQUID_NET" >> /etc/squid/squid.conf 
    fi
}


cat <<EOF >> /etc/squid/squid.conf

#
# docker-squid container specific options
#

EOF


apply_cache_effective_user_group
apply_cache_mem
apply_maximum_object_size_in_memory
apply_memory_replacement_policy
apply_cache_dir
apply_maximum_object_size
apply_cache_replacement_policy
apply_user_network_cidr


echo "Running $@"
cat << EOF 
  ... used docker-proxy container environment variables:
  SQUID_EFFECTIVE_USER=${SQUID_EFFECTIVE_USER}
  SQUID_EFFECTIVE_GROUP=${SQUID_EFFECTIVE_GROUP}
  SQUID_CACHE_MEM=${SQUID_CACHE_MEM} MB
  SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY=${SQUID_MAXIMUM_OBJECT_SIZE_IN_MEMORY} KB
  SQUID_MEMORY_REPLACEMENT_POLICY=${SQUID_MEMORY_REPLACEMENT_POLICY}
  SQUID_CACHE_DIR=${SQUID_CACHE_DIR}
  SQUID_CACHE_SIZE=${SQUID_CACHE_SIZE} MB
  SQUID_MAXIMUM_OBJECT_SIZE=${SQUID_MAXIMUM_OBJECT_SIZE} MB
  SQUID_CACHE_REPLACEMENT_POLICY=${SQUID_CACHE_REPLACEMENT_POLICY}
EOF

[ ${SQUID_NET+x} ] && echo "  SQUID_NET=${SQUID_NET}/${SQUID_NET_CIDR}"


exec "$@"
