import os
import json
from PIL import Image

src_path = 'assets/images/kin - k logo bk.png'
src = Image.open(src_path).convert('RGBA')
bbox = src.getbbox()
k_mark = src.crop(bbox)

def make_icon(size, bg_color=(255, 255, 255, 255), padding_ratio=0.18, is_rgb=False):
    canvas = Image.new('RGBA', (size, size), bg_color)
    target_height = max(1, int(size * (1.0 - 2 * padding_ratio)))
    aspect = k_mark.width / k_mark.height
    target_width = max(1, int(target_height * aspect))
    resized_mark = k_mark.resize((target_width, target_height), Image.Resampling.LANCZOS)
    x = (size - target_width) // 2
    y = (size - target_height) // 2
    canvas.paste(resized_mark, (x, y), resized_mark)
    if is_rgb:
        return canvas.convert('RGB')
    return canvas

# 1. Web Icons
os.makedirs('web/icons', exist_ok=True)
favicon = make_icon(48, bg_color=(255, 255, 255, 255), padding_ratio=0.10)
favicon.save('web/favicon.png', 'PNG')
print('Generated web/favicon.png')

icon192 = make_icon(192, bg_color=(255, 255, 255, 255), padding_ratio=0.18, is_rgb=True)
icon192.save('web/icons/Icon-192.png', 'PNG')
print('Generated web/icons/Icon-192.png')

icon512 = make_icon(512, bg_color=(255, 255, 255, 255), padding_ratio=0.18, is_rgb=True)
icon512.save('web/icons/Icon-512.png', 'PNG')
print('Generated web/icons/Icon-512.png')

icon_mask192 = make_icon(192, bg_color=(255, 255, 255, 255), padding_ratio=0.25)
icon_mask192.save('web/icons/Icon-maskable-192.png', 'PNG')
print('Generated web/icons/Icon-maskable-192.png')

icon_mask512 = make_icon(512, bg_color=(255, 255, 255, 255), padding_ratio=0.25)
icon_mask512.save('web/icons/Icon-maskable-512.png', 'PNG')
print('Generated web/icons/Icon-maskable-512.png')

# 2. Android Mipmaps
android_sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

for folder, sz in android_sizes.items():
    dirpath = os.path.join('android/app/src/main/res', folder)
    if os.path.exists(dirpath):
        ic = make_icon(sz, bg_color=(255, 255, 255, 255), padding_ratio=0.16)
        ic.save(os.path.join(dirpath, 'ic_launcher.png'), 'PNG')
        print(f'Generated Android {folder}/ic_launcher.png ({sz}x{sz})')

# 3. iOS Icons
ios_dir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset'
contents_json = os.path.join(ios_dir, 'Contents.json')
if os.path.exists(contents_json):
    with open(contents_json, 'r') as f:
        data = json.load(f)
    for img in data.get('images', []):
        filename = img.get('filename')
        size_str = img.get('size', '20x20')
        scale_str = img.get('scale', '1x')
        base_size = float(size_str.split('x')[0])
        scale = float(scale_str.replace('x', ''))
        px = int(round(base_size * scale))
        if filename:
            out_path = os.path.join(ios_dir, filename)
            ic = make_icon(px, bg_color=(255, 255, 255, 255), padding_ratio=0.18, is_rgb=True)
            ic.save(out_path, 'PNG')
            print(f'Generated iOS {filename} ({px}x{px})')

print('All Kin icons successfully generated!')
