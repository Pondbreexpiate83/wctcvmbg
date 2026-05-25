# OnePlus 12 Kernel Build

## Информация

- **Устройство**: OnePlus 12
- **Платформа**: Qualcomm SM8650 (Snapdragon 8 Gen 3)
- **Кодовое имя платформы**: pineapple
- **Ядро**: Linux 6.1 (GKI)
- **Манифест**: `oneplus_12_v.xml` (Android 15)
- **Источник**: [OnePlusOSS/kernel_manifest](https://github.com/OnePlusOSS/kernel_manifest) (ветка `oneplus/sm8650`)

## Результаты сборки

| Артефакт | Размер | Описание |
|----------|--------|----------|
| `Image` | 35 MB | Ядро Linux (aarch64) |
| `boot.img` | 96 MB | Boot image (с AVB подписью) |
| `vendor_boot.img` | 34 MB | Vendor boot image |
| `dtb.img` | 3.2 MB | Device Tree Blob |
| `dtbo.img` | 3.8 MB | Device Tree Blob Overlay |
| `vendor_dlkm.img` | 244 MB | Vendor DLKM (модули ядра) |
| `super.img` | 255 MB | Super image (system_dlkm + vendor_dlkm) |

**Количество модулей ядра (.ko)**: 1522

## Как собрать

### Быстрый способ

```bash
chmod +x build_kernel_op12.sh
./build_kernel_op12.sh
```

### Пошаговая инструкция

```bash
# 1. Установить зависимости
sudo apt-get install -y build-essential bc bison flex libssl-dev libelf-dev \
    git curl python3 zip unzip rsync cpio lz4 repo \
    gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# 2. Инициализировать репозиторий
mkdir -p ~/kernel_op12 && cd ~/kernel_op12
repo init -u https://github.com/OnePlusOSS/kernel_manifest \
    -b oneplus/sm8650 -m oneplus_12_v.xml --depth=1

# 3. Синхронизировать исходники
repo sync -j$(nproc) --force-sync

# 4. Подготовить окружение
mkdir -p out/target/product/pineapple
mkdir -p vendor/oplus/kernel/prebuilt
echo "#!/bin/bash" > vendor/oplus/kernel/prebuilt/vendorsetup.sh

# 5. Собрать ядро
cd kernel_platform
./tools/bazel build \
    --pgo=none \
    --//msm-kernel:skip_abl=true \
    --//msm-kernel:skip_abi=true \
    --config=stamp \
    --user_kmi_symbol_lists=//msm-kernel:android/abi_gki_aarch64_qcom \
    --ignore_missing_projects \
    //msm-kernel:pineapple_gki_dist \
    //msm-kernel:pineapple_gki_dtc_dist
```

## Доступные манифесты

| Манифест | Версия Android |
|----------|----------------|
| `oneplus_12_u.xml` | Android 14 |
| `oneplus_12_v.xml` | Android 15 |
| `oneplus_12_b.xml` | Новейший |

## Прошивка

```bash
# Разблокировать загрузчик (если не разблокирован)
fastboot oem unlock

# Прошить ядро
fastboot flash boot boot.img
fastboot flash vendor_boot vendor_boot.img
fastboot flash dtbo dtbo.img
fastboot flash vendor_dlkm vendor_dlkm.img

# Перезагрузить
fastboot reboot
```

## Требования к системе

- **ОС**: Ubuntu 22.04+ (x86_64)
- **RAM**: минимум 8 GB (рекомендуется 16+ GB)
- **Диск**: минимум 80 GB свободного места
- **CPU**: чем больше ядер, тем быстрее (на 2 ядрах ~41 минут)

## Примечания

- Сборка использует Bazel (Kleaf) — систему сборки Android ядра
- Toolchain: встроенный Clang из AOSP prebuilts (clang-r487747c)
- GKI (Generic Kernel Image) версия 6.1 для Android 15
