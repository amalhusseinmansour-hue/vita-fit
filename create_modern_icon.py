from PIL import Image, ImageDraw, ImageFont
import math
import sys
import io

# Fix encoding for Windows console
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def create_modern_gradient_icon():
    # إنشاء صورة بحجم 1024x1024 (حجم قياسي للأيقونات)
    size = 1024
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # إنشاء تدرج دائري مودرن
    center_x, center_y = size // 2, size // 2
    max_radius = size // 2

    # الألوان البينك المودرن
    color_outer = (255, 105, 180)  # Hot Pink
    color_middle = (255, 20, 147)  # Deep Pink
    color_inner = (255, 182, 193)  # Light Pink

    # رسم التدرج الدائري
    for i in range(max_radius, 0, -1):
        # حساب نسبة التدرج
        ratio = i / max_radius

        if ratio > 0.7:
            # الطبقة الخارجية
            t = (ratio - 0.7) / 0.3
            r = int(color_outer[0] * t + color_middle[0] * (1 - t))
            g = int(color_outer[1] * t + color_middle[1] * (1 - t))
            b = int(color_outer[2] * t + color_middle[2] * (1 - t))
        else:
            # الطبقة الداخلية
            t = ratio / 0.7
            r = int(color_middle[0] * t + color_inner[0] * (1 - t))
            g = int(color_middle[1] * t + color_inner[1] * (1 - t))
            b = int(color_middle[2] * t + color_inner[2] * (1 - t))

        color = (r, g, b, 255)
        draw.ellipse([center_x - i, center_y - i, center_x + i, center_y + i],
                     fill=color)

    # إضافة دائرة بيضاء في المنتصف للتباين
    white_radius = size // 3
    draw.ellipse([center_x - white_radius, center_y - white_radius,
                  center_x + white_radius, center_y + white_radius],
                 fill=(255, 255, 255, 255))

    # رسم أيقونة دمبل رياضي مودرن في المنتصف
    # الجزء الأيسر من الدمبل
    dumbbell_width = size // 8
    dumbbell_height = size // 20
    bar_width = size // 3
    bar_height = size // 25

    left_x = center_x - bar_width // 2 - dumbbell_width // 2
    right_x = center_x + bar_width // 2 - dumbbell_width // 2
    y = center_y - dumbbell_height // 2

    # رسم الأجزاء الجانبية للدمبل
    pink_color = (255, 105, 180, 255)

    # الجزء الأيسر
    draw.rounded_rectangle([left_x, y, left_x + dumbbell_width, y + dumbbell_height],
                          radius=dumbbell_height // 3, fill=pink_color)

    # الجزء الأيمن
    draw.rounded_rectangle([right_x, y, right_x + dumbbell_width, y + dumbbell_height],
                          radius=dumbbell_height // 3, fill=pink_color)

    # البار الأوسط
    bar_y = center_y - bar_height // 2
    draw.rounded_rectangle([center_x - bar_width // 2, bar_y,
                          center_x + bar_width // 2, bar_y + bar_height],
                          radius=bar_height // 2, fill=pink_color)

    # إضافة نجمة لامعة في الزاوية
    star_size = size // 8
    star_x = center_x + size // 3
    star_y = center_y - size // 3

    # رسم نجمة بسيطة
    points = []
    for i in range(10):
        angle = (i * 36 - 90) * math.pi / 180
        if i % 2 == 0:
            radius = star_size // 2
        else:
            radius = star_size // 4
        x = star_x + radius * math.cos(angle)
        y = star_y + radius * math.sin(angle)
        points.append((x, y))

    draw.polygon(points, fill=(255, 215, 0, 255))  # لون ذهبي

    # إضافة قلب صغير
    heart_size = size // 10
    heart_x = center_x - size // 3
    heart_y = center_y + size // 3

    # رسم قلب بسيط
    draw.ellipse([heart_x - heart_size // 3, heart_y - heart_size // 3,
                  heart_x + heart_size // 3, heart_y],
                 fill=(255, 20, 147, 255))
    draw.ellipse([heart_x, heart_y - heart_size // 3,
                  heart_x + heart_size * 2 // 3, heart_y],
                 fill=(255, 20, 147, 255))
    draw.polygon([(heart_x - heart_size // 3, heart_y),
                  (heart_x + heart_size // 3, heart_y + heart_size // 2),
                  (heart_x + heart_size * 2 // 3, heart_y)],
                 fill=(255, 20, 147, 255))

    return image

def create_adaptive_icon():
    # إنشاء أيقونة adaptive لـ Android
    size = 1024
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # خلفية بتدرج بينك مودرن
    for y in range(size):
        ratio = y / size
        r = int(255 * (1 - ratio * 0.3))
        g = int(105 + (182 - 105) * ratio)
        b = int(180 + (193 - 180) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    # رسم شكل دائري في المنتصف
    center_x, center_y = size // 2, size // 2
    radius = size // 3

    # دائرة بيضاء شبه شفافة
    draw.ellipse([center_x - radius, center_y - radius,
                  center_x + radius, center_y + radius],
                 fill=(255, 255, 255, 200))

    # أيقونة دمبل مودرن
    dumbbell_width = size // 6
    dumbbell_height = size // 15
    bar_width = size // 4
    bar_height = size // 20

    left_x = center_x - bar_width // 2 - dumbbell_width // 2
    right_x = center_x + bar_width // 2 - dumbbell_width // 2
    y = center_y - dumbbell_height // 2

    pink_color = (255, 20, 147, 255)

    # الأجزاء الجانبية
    draw.rounded_rectangle([left_x, y, left_x + dumbbell_width, y + dumbbell_height],
                          radius=dumbbell_height // 3, fill=pink_color)
    draw.rounded_rectangle([right_x, y, right_x + dumbbell_width, y + dumbbell_height],
                          radius=dumbbell_height // 3, fill=pink_color)

    # البار
    bar_y = center_y - bar_height // 2
    draw.rounded_rectangle([center_x - bar_width // 2, bar_y,
                          center_x + bar_width // 2, bar_y + bar_height],
                          radius=bar_height // 2, fill=pink_color)

    return image

# إنشاء الأيقونات
print("🎨 جاري إنشاء الأيقونة المودرن...")
icon = create_modern_gradient_icon()
icon.save('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png')
print("✅ تم حفظ ic_launcher.png (xxxhdpi)")

# حفظ بأحجام مختلفة
sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192
}

for density, size in sizes.items():
    resized = icon.resize((size, size), Image.Resampling.LANCZOS)
    path = f'android/app/src/main/res/mipmap-{density}/ic_launcher.png'
    resized.save(path)
    print(f"✅ تم حفظ {density}: {size}x{size}")

# إنشاء أيقونة adaptive
print("\n🎨 جاري إنشاء الأيقونة Adaptive...")
adaptive_icon = create_adaptive_icon()
adaptive_icon.save('android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png')

for density, size in sizes.items():
    resized = adaptive_icon.resize((size, size), Image.Resampling.LANCZOS)
    path = f'android/app/src/main/res/mipmap-{density}/ic_launcher_foreground.png'
    resized.save(path)
    print(f"✅ تم حفظ adaptive {density}: {size}x{size}")

print("\n🎉 تم إنشاء جميع الأيقونات بنجاح!")
print("💕 الأيقونة الجديدة بألوان بينك مودرن وجذابة جاهزة!")
