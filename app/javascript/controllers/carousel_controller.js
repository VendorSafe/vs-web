import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="carousel"
export default class extends Controller {
  static targets = ["container", "slide", "next", "prev", "indicator", "progress"]

  initialize() {
    // Ensure Flowbite is available
    if (!window.Flowbite) {
      console.error("Flowbite not found. Check application.js initialization.");
      return;
    }
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
    if (!window.FlowbiteCarousel) return;

    // Create items array from slides
    const items = this.slideTargets.map((slide, index) => ({
      position: index,
      el: slide
    }));

    // Create indicators array
    const indicators = this.indicatorTargets.map((indicator, index) => ({
      position: index,
      el: indicator
    }));

    const options = {
      defaultPosition: 0,
      interval: this.hasIntervalValue ? this.intervalValue : 5000,
      indicators: {
        items: indicators,
        activeClasses: "bg-primary",
        inactiveClasses: "bg-gray-300 hover:bg-gray-400"
      },
      onNext: () => this.handleSlideChange(),
      onPrev: () => this.handleSlideChange(),
      onChange: () => this.handleSlideChange()
    };

    // Instance options for Flowbite
    const instanceOptions = {
      id: this.element.id || `carousel-${Date.now()}`,
      override: true
    };

    try {
      const { Carousel } = window.Flowbite;
      this.carousel = new Carousel(
        this.containerTarget,
        items,
        options,
        instanceOptions
      );

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
    this.carousel?.next()
  }

  prev() {
    this.carousel?.prev()
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