def test_mountfolders_exist_and_is_folder(host):
    mnt2 = host.file("/mnt2")
    mnt3 = host.file("/mnt3")
    assert mnt2.exists
    assert mnt3.exists
    assert mnt2.is_directory
    assert mnt3.is_directory

def test_mountfolders_belong_to_myuser(host):
    assert host.file("/mnt2").user == "myuser"
    assert host.file("/mnt3").user == "myuser"

def test_devices_mounted_correctly(host):
    assert host.mount_point("/mnt2").device == "/dev/sdc"
    assert host.mount_point("/mnt3").device == "/dev/sdd"

def test_tmpdisk_is_present_and_ext4(host):
    assert host.mount_point("/mnt").device == "/dev/sdb1"
    assert host.mount_point("/mnt").filesystem == "ext4"
