from PIL import Image, ImageDraw
import math
import sys
import io

# Fix encoding for Windows console
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def create_elegant_icon():
    """Create a simple, elegant pink icon with a heart and fitness theme"""
    size = 1024
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    center_x, center_y = size // 2, size // 2

    # Create smooth circular gradient background
    max_radius = size // 2

    # Beautiful pink gradient colors
    color_start = (255, 105, 180)  # Hot Pink
    color_end = (255, 182, 193)    # Light Pink

    # Draw gradient circle
    for i in range(max_radius, 0, -1):
        ratio = i / max_radius
        r = int(color_start[0] * ratio + color_end[0] * (1 - ratio))
        g = int(color_start[1] * ratio + color_end[1] * (1 - ratio))
        b = int(color_start[2] * ratio + color_end[2] * (1 - ratio))

        draw.ellipse(
            [center_x - i, center_y - i, center_x + i, center_y + i],
            fill=(r, g, b, 255)
        )

    # Add white inner circle for contrast
    inner_radius = size // 2.5
    draw.ellipse(
        [center_x - inner_radius, center_y - inner_radius,
         center_x + inner_radius, center_y + inner_radius],
        fill=(255, 255, 255, 255)
    )

    # Draw an elegant heart shape
    heart_size = size // 4
    heart_x = center_x
    heart_y = center_y - heart_size // 6

    # Create heart using circles and triangle
    deep_pink = (255, 20, 147, 255)

    # Left circle of heart
    left_circle_x = heart_x - heart_size // 4
    left_circle_y = heart_y
    draw.ellipse(
        [left_circle_x - heart_size // 4, left_circle_y - heart_size // 4,
         left_circle_x + heart_size // 4, left_circle_y + heart_size // 4],
        fill=deep_pink
    )

    # Right circle of heart
    right_circle_x = heart_x + heart_size // 4
    right_circle_y = heart_y
    draw.ellipse(
        [right_circle_x - heart_size // 4, right_circle_y - heart_size // 4,
         right_circle_x + heart_size // 4, right_circle_y + heart_size // 4],
        fill=deep_pink
    )

    # Triangle bottom of heart
    draw.polygon([
        (heart_x - heart_size // 2, heart_y),
        (heart_x, heart_y + heart_size // 1.2),
        (heart_x + heart_size // 2, heart_y)
    ], fill=deep_pink)

    # Add a small fitness pulse line inside the heart
    pulse_color = (255, 255, 255, 255)
    pulse_width = 4

    # Draw pulse line (heartbeat)
    pulse_points = [
        (heart_x - heart_size // 3, heart_y + heart_size // 8),
        (heart_x - heart_size // 5, heart_y + heart_size // 8),
        (heart_x - heart_size // 8, heart_y - heart_size // 10),
        (heart_x, heart_y + heart_size // 4),
        (heart_x + heart_size // 8, heart_y),
        (heart_x + heart_size // 5, heart_y + heart_size // 8),
        (heart_x + heart_size // 3, heart_y + heart_size // 8),
    ]

    for i in range(len(pulse_points) - 1):
        draw.line([pulse_points[i], pulse_points[i + 1]], fill=pulse_color, width=pulse_width)

    # Add subtle shine effect
    shine_radius = size // 5
    shine_x = center_x - size // 4
    shine_y = center_y - size // 4

    for i in range(shine_radius, 0, -1):
        alpha = int(50 * (1 - i / shine_radius))
        draw.ellipse(
            [shine_x - i, shine_y - i, shine_x + i, shine_y + i],
            fill=(255, 255, 255, alpha)
        )

    return image

def create_adaptive_foreground():
    """Create foreground for adaptive icon with proper safe zone padding"""
    size = 1024
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    center_x, center_y = size // 2, size // 2

    # Draw simple heart with pulse - smaller size for adaptive icon safe zone
    # Android adaptive icons need ~25% padding on each side
    heart_size = size // 5  # Reduced from size // 3 for proper padding
    heart_x = center_x
    heart_y = center_y

    deep_pink = (255, 20, 147, 255)

    # Left circle
    left_circle_x = heart_x - heart_size // 4
    left_circle_y = heart_y
    draw.ellipse(
        [left_circle_x - heart_size // 4, left_circle_y - heart_size // 4,
         left_circle_x + heart_size // 4, left_circle_y + heart_size // 4],
        fill=deep_pink
    )

    # Right circle
    right_circle_x = heart_x + heart_size // 4
    right_circle_y = heart_y
    draw.ellipse(
        [right_circle_x - heart_size // 4, right_circle_y - heart_size // 4,
         right_circle_x + heart_size // 4, right_circle_y + heart_size // 4],
        fill=deep_pink
    )

    # Triangle
    draw.polygon([
        (heart_x - heart_size // 2, heart_y),
        (heart_x, heart_y + heart_size // 1.2),
        (heart_x + heart_size // 2, heart_y)
    ], fill=deep_pink)

    # Pulse line
    pulse_color = (255, 255, 255, 255)
    pulse_points = [
        (heart_x - heart_size // 3, heart_y + heart_size // 8),
        (heart_x - heart_size // 5, heart_y + heart_size // 8),
        (heart_x - heart_size // 8, heart_y - heart_size // 10),
        (heart_x, heart_y + heart_size // 4),
        (heart_x + heart_size // 8, heart_y),
        (heart_x + heart_size // 5, heart_y + heart_size // 8),
        (heart_x + heart_size // 3, heart_y + heart_size // 8),
    ]

    for i in range(len(pulse_points) - 1):
        draw.line([pulse_points[i], pulse_points[i + 1]], fill=pulse_color, width=4)

    return image

def create_adaptive_background():
    """Create background for adaptive icon"""
    size = 1024
    image = Image.new('RGBA', (size, size), (255, 105, 180, 255))
    draw = ImageDraw.Draw(image)

    # Simple gradient
    for y in range(size):
        ratio = y / size
        r = int(255)
        g = int(105 + (182 - 105) * ratio)
        b = int(180 + (193 - 180) * ratio)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))

    return image

# Create icons
print("Creating elegant icon...")

# Main icon
icon = create_elegant_icon()

# Save in different sizes
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
    print(f"Saved {density}: {size}x{size}")

# Adaptive icon foreground
print("\nCreating adaptive foreground...")
foreground = create_adaptive_foreground()

for density, size in sizes.items():
    resized = foreground.resize((size, size), Image.Resampling.LANCZOS)
    path = f'android/app/src/main/res/mipmap-{density}/ic_launcher_foreground.png'
    resized.save(path)
    print(f"Saved adaptive foreground {density}: {size}x{size}")

# Adaptive icon background
print("\nCreating adaptive background...")
background = create_adaptive_background()

for density, size in sizes.items():
    resized = background.resize((size, size), Image.Resampling.LANCZOS)
    path = f'android/app/src/main/res/mipmap-{density}/ic_launcher_background.png'
    resized.save(path)
    print(f"Saved adaptive background {density}: {size}x{size}")

print("\nAll icons created successfully!")
print("Elegant pink heart icon with pulse line is ready!")
