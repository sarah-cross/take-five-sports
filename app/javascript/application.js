import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap";


//= require jquery3
//= require popper
//= require bootstrap-sprockets


document.addEventListener('DOMContentLoaded', function () {
  const videoCarousel = document.getElementById('videoCarousel');
  let startX = 0;
  let endX = 0;

  // Detect the start of a swipe
  videoCarousel.addEventListener('touchstart', function (e) {
    startX = e.touches[0].clientX;
  });

  // Detect the end of a swipe
  videoCarousel.addEventListener('touchmove', function (e) {
    endX = e.touches[0].clientX;
  });

  // Determine the direction of the swipe and trigger the appropriate carousel control
  videoCarousel.addEventListener('touchend', function () {
    if (startX - endX > 50) {
      // Swipe left - go to the next slide
      bootstrap.Carousel.getInstance(videoCarousel).next();
    } else if (endX - startX > 50) {
      // Swipe right - go to the previous slide
      bootstrap.Carousel.getInstance(videoCarousel).prev();
    }
    startX = 0;
    endX = 0;
  });
});




