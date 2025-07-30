<!-- Contact Page Content -->
<main class="page-content">
  <!-- Hero Section -->
  <section class="relative bg-gradient-to-br from-[var(--color-primary)] via-[var(--color-accent)] to-[var(--color-secondary)] text-white py-20">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
      <div class="text-center">
        <h1 class="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl mb-6">Get in Touch</h1>
        <p class="text-xl leading-8 text-white/90 max-w-3xl mx-auto">
          Connect with our research team, collaborate on projects, or learn more about our findings
        </p>
      </div>
    </div>
  </section>

  <!-- Contact Methods -->
  <section class="py-16 bg-white">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-16">
        <!-- GitHub -->
        <div class="text-center">
          <div class="w-16 h-16 bg-[var(--color-primary)] rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
            </svg>
          </div>
          <h3 class="text-xl font-bold text-[var(--color-primary)] mb-2">GitHub</h3>
          <p class="text-[var(--color-text-secondary)] mb-4">Access our code repositories and contribute</p>
          <p class="text-sm text-[var(--color-text-secondary)]">Find our individual GitHub profiles on the Team page</p>
        </div>

        <!-- LinkedIn -->
        <div class="text-center">
          <div class="w-16 h-16 bg-[var(--color-accent)] rounded-full flex items-center justify-center mx-auto mb-4">
            <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
              <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
            </svg>
          </div>
          <h3 class="text-xl font-bold text-[var(--color-primary)] mb-2">LinkedIn</h3>
          <p class="text-[var(--color-text-secondary)] mb-4">Connect with our team professionally</p>
          <p class="text-sm text-[var(--color-text-secondary)]">Professional networking profiles coming soon</p>
        </div>
      </div>
    </div>
  </section>

  <!-- Contact Form and Team Info -->
  <section class="py-16 bg-gradient-to-br from-[var(--color-background)] to-gray-50">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-16">
        <!-- Contact Form -->
        <div class="bg-white rounded-2xl shadow-xl p-8">
          <h2 class="text-2xl font-bold text-[var(--color-primary)] mb-6">Send us a Message</h2>
          
          <!-- Success Message -->
          {#if showSuccessMessage}
            <div class="mb-6 p-4 bg-green-100 border border-green-400 text-green-700 rounded-md">
              <div class="flex items-center">
                <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                ¡Gracias por tu mensaje! Te responderemos pronto.
              </div>
            </div>
          {/if}
          
          <!-- Error Message -->
          {#if showErrorMessage}
            <div class="mb-6 p-4 bg-red-100 border border-red-400 text-red-700 rounded-md">
              <div class="flex items-center">
                <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"/>
                </svg>
                {errorMessage}
              </div>
            </div>
          {/if}
          
          <form class="space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label for="firstName" class="block text-sm font-medium text-[var(--color-primary)] mb-2">First Name</label>
                <input type="text" id="firstName" name="firstName" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent" required>
              </div>
              <div>
                <label for="lastName" class="block text-sm font-medium text-[var(--color-primary)] mb-2">Last Name</label>
                <input type="text" id="lastName" name="lastName" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent" required>
              </div>
            </div>

            <div>
              <label for="email" class="block text-sm font-medium text-[var(--color-primary)] mb-2">Email</label>
              <input type="email" id="email" name="email" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent" required>
            </div>

            <div>
              <label for="organization" class="block text-sm font-medium text-[var(--color-primary)] mb-2">Organization</label>
              <input type="text" id="organization" name="organization" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent">
            </div>

            <div>
              <label for="subject" class="block text-sm font-medium text-[var(--color-primary)] mb-2">Subject</label>
              <select id="subject" name="subject" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent">
                <option value="">Select a topic</option>
                <option value="research">Research Collaboration</option>
                <option value="data">Data Access Request</option>
                <option value="media">Media Inquiry</option>
                <option value="policy">Policy Discussion</option>
                <option value="general">General Question</option>
                <option value="other">Other</option>
              </select>
            </div>

            <div>
              <label for="message" class="block text-sm font-medium text-[var(--color-primary)] mb-2">Message</label>
              <textarea id="message" name="message" rows="5" class="w-full p-3 border border-gray-300 rounded-md focus:ring-2 focus:ring-[var(--color-accent)] focus:border-transparent" placeholder="Tell us about your inquiry..." required></textarea>
            </div>

            <div class="flex items-start">
              <input type="checkbox" id="newsletter" name="newsletter" class="mt-1 mr-3">
              <label for="newsletter" class="text-sm text-[var(--color-text-secondary)]">
                I would like to receive updates about new research findings and publications
              </label>
            </div>

            <button type="submit" 
                    disabled={isSubmitting}
                    class="w-full bg-[var(--color-primary)] text-white py-3 px-6 rounded-md hover:bg-[var(--color-secondary)] transition-colors font-medium disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center">
              {#if isSubmitting}
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Enviando...
              {:else}
                Send Message
              {/if}
            </button>
          </form>
        </div>

        <!-- Team Information -->
        <div>
          <h2 class="text-2xl font-bold text-[var(--color-primary)] mb-8">Research Team</h2>
          
          <div class="space-y-6">
            <!-- Team Page Link Card -->
            <div class="bg-gradient-to-br from-[var(--color-primary)] to-[var(--color-accent)] rounded-lg shadow-lg p-6 text-white">
              <div class="flex items-center mb-4">
                <div class="w-16 h-16 bg-white/20 rounded-full flex items-center justify-center mr-4">
                  <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-bold text-white">Meet Our Team</h3>
                  <p class="text-white/90">Researchers & Collaborators</p>
                </div>
              </div>
              <p class="text-white/90 text-sm mb-4">
                Discover our dedicated team of researchers working to understand barriers to justice in the U.S. immigration system.
              </p>
              <div class="flex gap-3">
                <a href="/team" class="inline-flex items-center px-4 py-2 bg-white text-[var(--color-primary)] font-medium rounded-md hover:bg-gray-100 transition-colors text-sm">
                  View Full Team
                  <svg class="w-4 h-4 ml-2" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z"/>
                  </svg>
                </a>
              </div>
            </div>

            <!-- MIT Emerging Talent Card -->
            <div class="bg-white rounded-lg shadow-lg p-6">
              <div class="flex items-center mb-4">
                <div class="w-16 h-16 bg-[var(--color-accent)] rounded-full flex items-center justify-center mr-4">
                  <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                </div>
                <div>
                  <h3 class="text-lg font-bold text-[var(--color-primary)]">MIT Emerging Talent</h3>
                  <p class="text-[var(--color-text-secondary)]">Program Affiliation</p>
                </div>
              </div>
              <p class="text-[var(--color-text-secondary)] text-sm mb-4">
                This research is conducted as part of the MIT Emerging Talent program, fostering innovative approaches to critical social challenges.
              </p>
              <div class="flex gap-3">
                <a href="https://emergingtalent.mit.edu" target="_blank" rel="noopener noreferrer" 
                   class="text-[var(--color-accent)] hover:text-[var(--color-secondary)] text-sm">Program Website</a>
                <a href="https://emergingtalent.mit.edu" target="_blank" rel="noopener noreferrer" 
                   class="text-[var(--color-accent)] hover:text-[var(--color-secondary)] text-sm">Learn More</a>
              </div>
            </div>
          </div>

          <!-- Collaboration Opportunities -->
          <div class="mt-8 bg-gradient-to-br from-[var(--color-primary)] to-[var(--color-accent)] rounded-2xl p-6 text-white">
            <h3 class="text-xl font-bold mb-4">Collaboration Opportunities</h3>
            <p class="text-white/90 mb-4">
              We welcome collaborations with researchers, policy makers, legal professionals, and advocacy organizations.
            </p>
            <ul class="space-y-2 text-white/90 text-sm">
              <li class="flex items-center">
                <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Joint research projects
              </li>
              <li class="flex items-center">
                <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Data sharing partnerships
              </li>
              <li class="flex items-center">
                <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Policy consultation
              </li>
              <li class="flex items-center">
                <svg class="w-4 h-4 mr-2" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                </svg>
                Speaking engagements
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </section>

</main>

<script>
  import { onMount } from 'svelte';

  let isSubmitting = false;
  let showSuccessMessage = false;
  let showErrorMessage = false;
  let errorMessage = '';

  onMount(() => {
    // Add form submission handling
    const form = document.querySelector('form');
    if (form) {
      form.addEventListener('submit', handleFormSubmit);
    }
  });

  async function handleFormSubmit(event) {
    event.preventDefault();
    
    if (isSubmitting) return;
    
    isSubmitting = true;
    showSuccessMessage = false;
    showErrorMessage = false;
    
    try {
      // Get form data
      const formData = new FormData(event.target);
      const data = Object.fromEntries(formData.entries());
      
      // Convert checkbox to boolean
      data.newsletter = !!data.newsletter;
      
      // Send to API
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
      });
      
      const result = await response.json();
      
      if (response.ok) {
        showSuccessMessage = true;
        event.target.reset();
        
        // Hide success message after 5 seconds
        setTimeout(() => {
          showSuccessMessage = false;
        }, 5000);
      } else {
        throw new Error(result.error || 'Error al enviar el mensaje');
      }
      
    } catch (error) {
      console.error('Error sending contact form:', error);
      errorMessage = error.message || 'Error al enviar el mensaje. Por favor, inténtalo de nuevo.';
      showErrorMessage = true;
      
      // Hide error message after 5 seconds
      setTimeout(() => {
        showErrorMessage = false;
      }, 5000);
    } finally {
      isSubmitting = false;
    }
  }
</script>
