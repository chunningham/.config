(define-module (configs)
  #:use-module (rde features)
  #:use-module (rde features base)
  #:use-module (rde features gnupg)
  #:use-module (rde features keyboard)
  #:use-module (rde features system)
  #:use-module (rde features wm)
  #:use-module (rde features xdg)
  #:use-module (rde features password-utils)
  #:use-module (rde features version-control)
  #:use-module (rde features fontutils)
  #:use-module (rde features terminals)
  #:use-module (rde features tmux)
  #:use-module (rde features shells)
  #:use-module (rde features shellutils)
  #:use-module (rde features ssh)
  ;; #:use-module (rde features emacs)
  #:use-module (rde features linux)
  #:use-module (rde features bittorrent)
  #:use-module (rde features mail)
  #:use-module (rde features docker)
  #:use-module (rde features video)
  #:use-module (rde features markup)
  ;; #:use-module (gnu services)
  ;; #:use-module (gnu services nix)
  #:use-module (gnu system keyboard)
  #:use-module (gnu system file-systems)
  #:use-module (gnu system mapped-devices)
  #:use-module (gnu packages)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu system linux-initrd)
  #:use-module (rde packages)
  #:use-module (guix gexp)
  #:use-module (ice-9 match))


;;; User-specific features

;; Initial user's password hash will be available in store, so it's
;; use this feature with care
;; (display (crypt "hi" "$6$abc"))

(define* (mail-acc id user #:optional (type 'gmail))
  "Make a simple mail-account with gmail type by default."
  (mail-account
   (id   id)
   (fqda user)
   (type type)))

(define* (mail-lst id fqda urls)
  "Make a simple mailing-list."
  (mailing-list
   (id   id)
   (fqda fqda)
   (config (l2md-repo
            (name (symbol->string id))
            (urls urls)))))

(define %ch-features
  (list
   (feature-user-info
    #:user-name "ch"
    #:full-name "Ch"
    #:email "ch@rlescunningh.am"
    ;; #:user-initial-password-hash
    ;; "$6$abc$3SAZZQGdvQgAscM2gupP1tC.SqnsaLSPoAnEOb2k6jXMhzQqS1kCSplAJ/vUy2rrnpHtt6frW2Ap5l/tIvDsz."
    ;; (crypt "bob" "$6$abc")

    ;; WARNING: This option can reduce the explorability by hiding
    ;; some helpful messages and parts of the interface for the sake
    ;; of minimalistic, less distractive and clean look.  Generally
    ;; it's not recommended to use it.
    )
   ;; (feature-gnupg)
   ;; (feature-password-store
   ;;  #:remote-password-store-url "ssh://abcdw@olorin.lan/~/state/password-store")

   ;; (feature-mail-settings
   ;;  #:mail-accounts (list (mail-acc 'work       "andrew@trop.in")
   ;;                        (mail-acc 'personal   "andrewtropin@gmail.com"))
   ;;  #:mailing-lists (list (mail-lst 'guix-devel "guix-devel@gnu.org"
   ;;                                  '("https://yhetil.org/guix-devel/0"))
   ;;                        (mail-lst 'guix-bugs "guix-bugs@gnu.org"
   ;;                                  '("https://yhetil.org/guix-bugs/0"))
   ;;                        (mail-lst 'guix-patches "guix-patches@gnu.org"
   ;;                                  '("https://yhetil.org/guix-patches/1"))))

   (feature-keyboard
    #:keyboard-layout (keyboard-layout "au"
                                       #:options '("caps:swapescape")))))

;;; TODO: Add documentation about starting guile repl
;;; TODO: feature-wallpapers https://wallhaven.cc/
;;; TODO: feature-icecat
;;; TODO: feature-bash?
;;; TODO: feature-battery
;; PipeWire/iwd:
;; https://github.com/J-Lentz/iwgtk
;; https://github.com/krevedkokun/guix-config/blob/master/system/yggdrasil.scm


;;; Generic features should be applicable for various hosts/users/etc

(define* (pkgs #:rest lst)
  (map specification->package+output lst))

;;; WARNING: The order can be important for features extending
;;; services of other features.  Be careful changing it.
(define %main-features
  (list
   (feature-custom-services
    #:system-services
    (list
     ;; (service nix-service-type)
     )
    #:home-services
    (list
     ;; ((@ (gnu services) simple-service)
     ;;  'extend-shell-profile
     ;;  (@ (gnu home-services shells) home-shell-profile-service-type)
     ;;  (list
     ;;   #~(string-append
     ;;      "alias superls="
     ;;      #$(file-append (@ (gnu packages base) coreutils) "/bin/ls"))))
     ))

   (feature-kernel
    #:kernel linux
    #:firmware (list linux-firmware)
    #:initrd microcode-initrd)
   (feature-base-services)
   (feature-desktop-services)
   ;; (feature-docker)

   (feature-fonts)
   (feature-pipewire)
   (feature-backlight)

   (feature-alacritty
    #:config-file (local-file "./alacritty.yml"))
   ;; (feature-tmux
   ;;  #:config-file (local-file "./config/tmux/tmux.conf"))
   (feature-zsh)
   (feature-ssh)
   (feature-git
    #:sign-commits? #f)

   (feature-sway
    #:add-keyboard-layout-to-config? #f
    #:extra-config
    `((include ,(local-file "./swayconf"))))
   (feature-sway-run-on-tty
    #:sway-tty-number 2)
   (feature-sway-screenshot)
   (feature-sway-statusbar)

   ;; (feature-direnv)
   ;; (feature-markdown)

   (feature-mpv)
   ;; (feature-isync #:isync-verbose #t)
   ;; (feature-l2md)
   ;; (feature-msmtp)
   ;; (feature-transmission #:auto-start? #f)

   (feature-xdg
    #:xdg-user-directories-configuration
    (home-xdg-user-directories-configuration
     (music "$HOME/music")
     (videos "$HOME/vids")
     (pictures "$HOME/pics")
     (documents "$HOME/docs")
     (download "$HOME/dl")
     (desktop "$HOME")
     (publicshare "$HOME")
     (templates "$HOME")))
   (feature-base-packages
    #:home-packages
    (append
     (pkgs
      "alsa-utils" "youtube-dl" "imv"
      "obs" "obs-wlrobs"
      "recutils"
      "fheroes2"
      ;; TODO: Enable pipewire support to chromium by default
      ;; chrome://flags/#enable-webrtc-pipewire-capturer
      "ungoogled-chromium-wayland" "ublock-origin-chromium"
      "hicolor-icon-theme" "adwaita-icon-theme" "gnome-themes-standard"
      "ripgrep" "curl" "make")))))

(define %laptop-features
  (list ))


;;; Hardware/host specifis features

;; TODO: Switch from UUIDs to partition labels For better
;; reproducibilty and easier setup.  Grub doesn't support luks2 yet.

(define rles-mapped-devices
  (list (mapped-device
         (source (uuid "b53a556a-33a0-498d-91e9-0a541903f786"))
         (target "cryptroot")
         (type luks-device-mapping))))

(define rles-file-systems
  (list
   (file-system
    (type "btrfs")
    (device "/dev/mapper/cryptroot")
    (mount-point "/")
    (dependencies rles-mapped-devices))
   (file-system
    (mount-point "/boot/efi")
    (type "vfat")
    (device "/dev/nvme0n1p1"))))

(define %rles-features
  (list
   (feature-host-info
    #:host-name "rles"
    #:timezone  "Europe/Berlin")
   ;;; Allows to declare specific bootloader configuration,
   ;;; grub-efi-bootloader used by default
   ;; (feature-bootloader)
   (feature-file-systems
    #:mapped-devices rles-mapped-devices
    #:file-systems   rles-file-systems)
   (feature-hidpi)))


;;; rde-config and helpers for generating home-environment and
;;; operating-system records.

(define-public rles-config
  (rde-config
   (features
    (append
     %ch-features
     %main-features
     %rles-features))))

;; TODISCUSS: Make rde-config-os/he to be a feature instead of getter?
(define rles-os
  (rde-config-operating-system rles-config))
(define rles-he
  (rde-config-home-environment rles-config))

(define (dispatcher)
  (let ((rde-target (getenv "RDE_TARGET")))
    (match rde-target
      ("home" rles-he)
      ("system" rles-os)
      (_ rles-he))))

(dispatcher)
