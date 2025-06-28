// Desktop Blocker JavaScript - Simplified
class DesktopBlocker {
  constructor() {
    this.desktopBlocker = document.getElementById('desktopBlocker');
    this.mobileBreakpoint = 768;
    
    this.init();
  }

  init() {
    this.checkDevice();
    this.bindEvents();
  }

  checkDevice() {
    const isMobile = this.isMobileDevice() || window.innerWidth <= this.mobileBreakpoint;
    
    if (!isMobile) {
      this.showBlocker();
    } else {
      this.hideBlocker();
    }
  }

  isMobileDevice() {
    const userAgent = navigator.userAgent.toLowerCase();
    const mobileKeywords = [
      'android', 'webos', 'iphone', 'ipad', 'ipod', 
      'blackberry', 'iemobile', 'opera mini', 'mobile'
    ];
    
    return mobileKeywords.some(keyword => userAgent.includes(keyword));
  }

  showBlocker() {
    this.desktopBlocker.classList.add('show');
    this.logAccessAttempt();
  }

  hideBlocker() {
    this.desktopBlocker.classList.remove('show');
  }

  bindEvents() {
    window.addEventListener('load', () => this.checkDevice());
    window.addEventListener('resize', () => this.checkDevice());
    window.addEventListener('orientationchange', () => {
      setTimeout(() => this.checkDevice(), 100);
    });

    // Prevent right-click context menu on desktop blocker
    this.desktopBlocker.addEventListener('contextmenu', (e) => {
      e.preventDefault();
    });
  }

  logAccessAttempt() {
    // Log access attempt for analytics
    console.log('Desktop access blocked:', {
      userAgent: navigator.userAgent,
      screenSize: `${window.screen.width}x${window.screen.height}`,
      viewportSize: `${window.innerWidth}x${window.innerHeight}`,
      timestamp: new Date().toISOString(),
      url: window.location.href
    });
  }
}

// Initialize desktop blocker when DOM is loaded
let desktopBlockerInstance;

document.addEventListener('DOMContentLoaded', () => {
  desktopBlockerInstance = new DesktopBlocker();
  window.desktopBlocker = desktopBlockerInstance;
});

// Export for global access
window.DesktopBlocker = DesktopBlocker; 