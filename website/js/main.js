(function () {
    'use strict';

    // Unregister any service workers on the landing page
    // This prevents the game's PWA service worker from interfering
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.getRegistrations().then(function (registrations) {
            registrations.forEach(function (registration) {
                // Only unregister if we're on the landing page, not in /game/
                if (window.location.pathname === '/' || window.location.pathname === '/index.html') {
                    registration.unregister();
                }
            });
        });
    }

    var startButton = document.getElementById('startButton');

    if (startButton) {
        startButton.addEventListener('click', function (event) {
            event.preventDefault();

            var targetUrl = this.href;

            document.body.classList.add('fade-out');

            setTimeout(function () {
                window.location.href = targetUrl;
            }, 500);
        });
    }

    // Smooth video loop transition
    var video = document.querySelector('.background-video');

    if (video) {
        var fadeBuffer = 0.5;  // Start fade 0.5s before video ends
        var isFading = false;

        video.addEventListener('timeupdate', function () {
            // Check if we're near the end of the video
            if (video.duration && video.currentTime > 0) {
                var timeRemaining = video.duration - video.currentTime;

                // Start fading when approaching the end
                if (timeRemaining <= fadeBuffer && !isFading) {
                    isFading = true;
                    video.classList.add('video-fading');
                }

                // Remove fade class after video loops (currentTime resets)
                if (video.currentTime < fadeBuffer && isFading) {
                    // Small delay to let the loop complete before fading back in
                    setTimeout(function () {
                        video.classList.remove('video-fading');
                        isFading = false;
                    }, 100);
                }
            }
        });

        // Fallback: also listen for 'seeked' event in case timeupdate misses the loop
        video.addEventListener('seeked', function () {
            if (video.currentTime < 0.1 && isFading) {
                setTimeout(function () {
                    video.classList.remove('video-fading');
                    isFading = false;
                }, 100);
            }
        });
    }
})();