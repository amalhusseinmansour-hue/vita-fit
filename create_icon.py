#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to create app icon from SVG or create a simple PNG icon
"""
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

try:
    from PIL import Image, ImageDraw, ImageFont
    import os

    def create_gym_icon(size=1024):
        """Create a simple GYM app icon"""
        # Create image with gradient-like background
        img = Image.new('RGB', (size, size), color='#FF6B35')
        draw = ImageDraw.Draw(img)

        # Draw gradient effect (simplified)
        for i in range(size):
            color_value = int(255 - (i / size) * 50)
            r = min(255, int(255 - (i / size) * 100))
            g = min(255, int(107 + (i / size) * 40))
            b = 53
            draw.line([(0, i), (size, i)], fill=(r, g, b))

        # Draw dumbbell (simplified)
        white = (255, 255, 255)

        # Left weight
        draw.rounded_rectangle([150, 412, 270, 612], radius=20, fill=white)
        draw.rounded_rectangle([130, 432, 170, 592], radius=10, fill=white)

        # Right weight
        draw.rounded_rectangle([754, 412, 874, 612], radius=20, fill=white)
        draw.rounded_rectangle([854, 432, 894, 592], radius=10, fill=white)

        # Bar
        draw.rounded_rectangle([270, 487, 754, 537], radius=25, fill=white)

        # Grip lines
        grip_positions = [452, 482, 512, 542, 572]
        for x in grip_positions:
            draw.rounded_rectangle([x, 492, x+8, 532], radius=4, fill=(255, 107, 53, 150))

        # Try to add text
        try:
            font_size = 100
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            try:
                font = ImageFont.truetype("Arial.ttf", font_size)
            except:
                font = ImageFont.load_default()

        text = "GYM"
        # Get text bbox
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        text_x = (size - text_width) // 2
        text_y = 700

        # Draw text
        draw.text((text_x, text_y), text, fill=white, font=font)

        return img

    # Create icon
    print("Creating app icon...")
    icon = create_gym_icon(1024)

    # Save as PNG
    output_path = "assets/icons/icon.png"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    icon.save(output_path, "PNG")
    print(f"[OK] Icon saved to {output_path}")

    # Create different sizes for Android
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }

    print("\nCreating Android icons...")
    for folder, size in sizes.items():
        resized = icon.resize((size, size), Image.Resampling.LANCZOS)
        path = f"android/app/src/main/res/{folder}/ic_launcher.png"
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized.save(path, "PNG")
        print(f"[OK] {folder}: {size}x{size}")

    print("\n[SUCCESS] All icons created successfully!")

except ImportError:
    print("[WARNING] PIL/Pillow not installed. Installing...")
    import subprocess
    subprocess.run(["pip", "install", "pillow"])
    print("Please run the script again.")
except Exception as e:
    print(f"[ERROR] Error: {e}")
    print("\nYou can manually create the icon or use an online tool.")
