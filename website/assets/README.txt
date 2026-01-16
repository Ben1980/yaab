YAAB Background Media
=====================

Place your background video or screenshot here.

SUPPORTED FORMATS:

Video (recommended for engaging landing page):
- background.webm  (smaller file size, modern browsers)
- background.mp4   (broader compatibility, fallback)
- poster.jpg       (shown while video loads)

Image (simpler, faster loading):
- screenshot.png   (will have subtle zoom animation)
- screenshot.jpg   (alternative format)

AFTER ADDING MEDIA:

Edit website/index.html and:
1. Find the "BACKGROUND LAYERS" section
2. Comment out the animated gradient placeholder
3. Uncomment either the VIDEO or IMAGE background section
4. Update the file paths if your filenames differ

VIDEO TIPS:
- Keep videos short (10-15 second loop)
- Compress for web (target ~5-10MB max)
- Use tools like HandBrake or FFmpeg
- Muted autoplay is required by browsers
- Always provide MP4 as fallback for Safari

IMAGE TIPS:
- Use a representative gameplay screenshot
- Recommended size: 1920x1080 or larger
- For pixel art, use PNG to preserve sharp pixels
- The CSS adds a subtle Ken Burns (zoom) effect

PLACEHOLDER:
Until you add your own media, the landing page uses
an animated CSS gradient that gives a retro space feel.
