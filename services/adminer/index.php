<?php
// iota — Custom Adminer entry point with auto-login.
// Mounted into the iota_adminer container at /var/www/html/index.php.
// Uses MySQL root credentials since this is a local dev tool.
//
// The compiled adminer.php uses `namespace Adminer`, so the base class
// is \Adminer\Adminer (not \Adminer).

namespace iota {
    function adminer_object() {
        class Adminer extends \Adminer\Adminer {
            function name() {
                return '⚡ iota';
            }

            function credentials() {
                return ['iota_mysql', 'root', 'iota_root_secret'];
            }

            function login($login, $password) {
                return true;
            }
        }
        return new Adminer();
    }
}

namespace {
    // Auto-login: if not already authenticated, inject POST auth data.
    // Adminer will process this as a login submission, set the session,
    // and redirect to ?username=root. No JavaScript or form needed.
    if (empty($_GET['username']) && empty($_POST['auth'])) {
        $_POST['auth'] = [
            'driver' => 'server',
            'server' => 'iota_mysql',
            'username' => 'root',
            'password' => 'iota_root_secret',
            'db' => '',
            'permanent' => '1',
        ];
    }

    function adminer_object() {
        return \iota\adminer_object();
    }

    require 'adminer.php';
}
