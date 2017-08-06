#!/bin/sh

# ---------------------- [START] wordpress installation ---------------------- #
install_wordpress () {
  # make directory for wordpress updates and set permissions
  tar xzvf ${WORDPRESS_TARBALL} --directory ${DOCUMENT_ROOT} --strip-components=1 && \
  mkdir -p ${DOCUMENT_ROOT}/wp-content/upgrade
}
# ----------------------- [END] wordpress installation ----------------------- #

# -------------------- [START] wordpress config generator -------------------- #
generate_wp_config () {
  cat > ${DOCUMENT_ROOT}/wp-config.php <<EOF
<?php
  // ** MySQL settings - You can get this info from your web host ** //
  /** The name of the database for WordPress */
  define('DB_NAME', ${DATABASE});

  /** MySQL database username */
  define('DB_USER', ${DB_USER});

  /** MySQL database password */
  define('DB_PASSWORD', ${DB_PASSWORD});

  /** MySQL hostname */
  define('DB_HOST', ${DB_HOST});

  /** File system write method */
  define('FS_METHOD', 'direct');

  /** Database Charset to use in creating database tables. */
  define('DB_CHARSET', 'utf8');

  /** The Database Collate type. Dont change this if in doubt. */
  define('DB_COLLATE', '');
EOF
  # generate secure secret keys for wordpress internals
  curl -s ${WORDPRESS_SECRET_GENERATION_API} >> ${DOCUMENT_ROOT}/wp-config.php && \
  cat >> ${DOCUMENT_ROOT}/wp-config.php <<EOF
  /**
  * WordPress Database Table prefix.
  *
  * You can have multiple installations in one database if you give each
  * a unique prefix. Only numbers, letters, and underscores please!
  */
  \$table_prefix  = 'wp_';

  /**
  * For developers: WordPress debugging mode.
  *
  * Change this to true to enable the display of notices during development.
  * It is strongly recommended that plugin and theme developers use WP_DEBUG
  * in their development environments.
  *
  * For information on other constants that can be used for debugging,
  * visit the Codex.
  *
  * @link https://codex.wordpress.org/Debugging_in_WordPress
  */
  define('WP_DEBUG', false);

  /* Thats all, stop editing! Happy blogging. */

  /** Absolute path to the WordPress directory. */
  if ( !defined('ABSPATH') )
   define('ABSPATH', dirname(__FILE__) . '/');

  /** Sets up WordPress vars and included files. */
  require_once(ABSPATH . 'wp-settings.php');
EOF
}
# --------------------- [END] wordpress config generator --------------------- #

# ------------------ [START] set document root permissions ------------------- #
set_wordpress_permissions() {
  # setgid bit on each directory
  # group write access so web interface can make theme/plugin changes
  chown -R wordpress:www-data ${DOCUMENT_ROOT} && \
  find ${DOCUMENT_ROOT} -type d -exec chmod g+s {} \; && \
  chmod g+w ${DOCUMENT_ROOT}/wp-content && \
  chmod -R g+w ${DOCUMENT_ROOT}/wp-content/themes && \
  chmod -R g+w ${DOCUMENT_ROOT}/wp-content/plugins
}
# ------------------- [END] set document root permissions -------------------- #

# ----------------------- [START] configuration logic ------------------------ #
# install wp into document root if not already there
if [ ! -d ${DOCUMENT_ROOT}/wp-content ]; then
  install_wordpress
fi

# generate wp-config.php file if it doesn't already exist
if [ ! -f ${DOCUMENT_ROOT}/wp-config.php ]; then
  generate_wp_config
fi

rm -f ${WORDPRESS_TARBALL}

set_wordpress_permissions
# ------------------------ [END] configuration logic ------------------------- #

php-fpm
