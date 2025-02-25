import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["container", "slide", "next", "prev", "indicator", "progress"]

  initialize() {
    // Ensure Flowbite is available
    if (!window.Flowbite?.Carousel) {
      console.error("Flowbite Carousel not found. Check application.js initialization.");
      // Initialize basic carousel functionality without Flowbite
      this.initializeBasicCarousel();
      return;
    }
  }

  initializeBasicCarousel() {
    this.currentIndex = 0;
    this.updateSlideVisibility();
    this.updateProgress();
  }

  updateSlideVisibility() {
    this.slideTargets.forEach((slide, index) => {
      if (index === this.currentIndex) {
        slide.classList.remove('hidden');
        slide.classList.add('active');
      } else {
        slide.classList.add('hidden');
        slide.classList.remove('active');
      }
    });
  }
  static values = {
    interval: { type: Number, default: 5000 },
    wrap: { type: Boolean, default: true },
    touch: { type: Boolean, default: true }
  }

  connect() {
    this.initializeCarousel()
    this.setupKeyboardNavigation()
    this.updateProgress()
  }

  disconnect() {
    this.carousel?.destroy()
    this.removeKeyboardListener()
  }

  initializeCarousel() {
    if (!window.Flowbite?.Carousel) return;

    try {
      const options = {
        defaultPosition: 0,
        interval: this.hasIntervalValue ? this.intervalValue : 5000,
        indicators: {
          activeClasses: "bg-primary active",
          inactiveClasses: "bg-gray-300 hover:bg-gray-400"
        }
      };

      this.carousel = new window.Flowbite.Carousel(this.containerTarget, options);

      // Store initial state for Turbo navigation
      this.storeState();
    } catch (error) {
      console.error("Failed to initialize carousel:", error);
    }
  }

  setupKeyboardNavigation() {
    this.keydownHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.keydownHandler)
  }

  removeKeyboardListener() {
    document.removeEventListener("keydown", this.keydownHandler)
  }

  handleKeydown(event) {
    if (event.key === "ArrowRight") {
      this.next()
    } else if (event.key === "ArrowLeft") {
      this.prev()
    }
  }

  next() {
    if (this.carousel) {
      this.carousel.next()
    } else {
      this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
      this.updateSlideVisibility()
      this.updateProgress()
    }
  }

  prev() {
    if (this.carousel) {
      this.carousel.prev()
    } else {
      this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
      this.updateSlideVisibility()
      this.updateProgress()
    }
  }

  handleSlideChange() {
    this.updateProgress()
    this.storeState()
  }

  updateProgress() {
    if (!this.hasProgressTarget) return

    const totalSlides = this.slideTargets.length
    const currentIndex = this.getCurrentIndex()
    const progress = Math.round((currentIndex / (totalSlides - 1)) * 100)

    this.progressTarget.setAttribute("data-progress", progress.toString())
    this.progressTarget.style.width = `${progress}%`
  }

  getCurrentIndex() {
    return this.slideTargets.findIndex(slide =>
      slide.classList.contains("active")
    )
  }

  // Handle Turbo navigation state
  storeState() {
    sessionStorage.setItem(
      `carousel-${this.element.id}`,
      this.getCurrentIndex().toString()
    )
  }

  restoreState() {
    const storedIndex = sessionStorage.getItem(`carousel-${this.element.id}`)
    if (storedIndex !== null) {
      this.carousel?.slideTo(parseInt(storedIndex))
    }
  }
}