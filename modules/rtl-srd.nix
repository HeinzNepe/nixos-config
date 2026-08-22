{ config, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        # Core RTL-SDR drivers
        rtl-sdr
        soapysdr
        soapysdr-with-plugins
        soapyrtlsdr

        # GUI SDR receivers
        gqrx
        cubicsdr
        welle-io

        # Spectrum analysis
        #qspectrumanalyzer

        # CLI demodulator
        #rtl-sdr.rtl_fm

        # Optional ADS-B stack
        dump1090-fa
        readsb
    ];

    # Udev rules for RTL-SDR Blog V3
    services.udev.extraRules = ''
        SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="2838", GROUP="plugdev", MODE="0666"
        SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="2832", GROUP="plugdev", MODE="0666"
    '';

    boot.blacklistedKernelModules = [
        "dvb_usb_rtl28xxu"
        "rtl2832"
        "rtl2830"
    ];


    users.groups.plugdev = { };
    users.users.henrik.extraGroups = [ "plugdev" ];
}
