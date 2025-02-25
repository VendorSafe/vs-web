<script setup>
import { ref, computed, onMounted } from "vue";

const props = defineProps({
  certificateId: {
    type: [String, Number],
    required: true,
  },
  trainingProgram: {
    type: Object,
    required: true,
  },
  userName: {
    type: String,
    required: true,
  },
});

const emit = defineEmits(["download", "regenerate"]);

const isLoading = ref(true);
const error = ref(null);
const certificate = ref(null);
const pdfUrl = ref(null);

const statusClass = computed(() => {
  if (!certificate.value) return "";
  
  if (certificate.value.revoked_at) {
    return "bg-red-100 text-red-800";
  }
  
  if (certificate.value.expires_at && new Date(certificate.value.expires_at) < new Date()) {
    return "bg-yellow-100 text-yellow-800";
  }
  
  return "bg-green-100 text-green-800";
});

const statusText = computed(() => {
  if (!certificate.value) return "";
  
  if (certificate.value.revoked_at) {
    return "Revoked";
  }
  
  if (certificate.value.expires_at && new Date(certificate.value.expires_at) < new Date()) {
    return "Expired";
  }
  
  return "Valid";
});

const pdfStatus = computed(() => {
  if (!certificate.value) return "";
  return certificate.value.pdf_status;
});

const isPdfReady = computed(() => {
  return pdfStatus.value === "completed";
});

const isPdfProcessing = computed(() => {
  return pdfStatus.value === "processing";
});

const isPdfFailed = computed(() => {
  return pdfStatus.value === "failed";
});

const formattedDate = (dateString) => {
  if (!dateString) return "";
  const date = new Date(dateString);
  return date.toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
};

const fetchCertificate = async () => {
  isLoading.value = true;
  error.value = null;
  
  try {
    const response = await fetch(`/training_certificates/${props.certificateId}.json`);
    if (!response.ok) {
      throw new Error("Failed to fetch certificate");
    }
    
    certificate.value = await response.json();
    
    if (isPdfReady.value) {
      pdfUrl.value = `/training_certificates/${props.certificateId}/download_pdf`;
    }
  } catch (err) {
    error.value = err.message;
  } finally {
    isLoading.value = false;
  }
};

const handleDownload = () => {
  if (isPdfReady.value) {
    emit("download", props.certificateId);
    window.open(pdfUrl.value, "_blank");
  }
};

const handleRegenerate = async () => {
  try {
    const response = await fetch(`/training_certificates/${props.certificateId}/regenerate_pdf`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
    });
    
    if (!response.ok) {
      throw new Error("Failed to regenerate certificate");
    }
    
    emit("regenerate", props.certificateId);
    fetchCertificate();
  } catch (err) {
    error.value = err.message;
  }
};

onMounted(() => {
  fetchCertificate();
});
</script>

<template>
  <div class="certificate-viewer">
    <div v-if="isLoading" class="text-center py-16">
      <div class="loading-spinner mx-auto"></div>
      <p class="mt-4 text-gray-600 animate-pulse">
        Loading certificate...
      </p>
    </div>

    <div v-else-if="error" class="text-center py-16">
      <div class="max-w-md mx-auto card card-body bg-red-50 border border-red-200">
        <p class="text-red-600">{{ error }}</p>
      </div>
    </div>

    <div v-else-if="certificate" class="certificate-container">
      <!-- Certificate Preview -->
      <div class="certificate-preview card">
        <div class="card-body">
          <div class="flex justify-between items-start mb-6">
            <h2 class="text-2xl font-bold text-secondary-800">Certificate of Completion</h2>
            <span class="badge" :class="statusClass">{{ statusText }}</span>
          </div>

          <div class="certificate-content">
            <p class="text-center text-gray-600 mb-4">This is to certify that</p>
            <p class="text-center text-xl font-bold text-secondary-800 mb-4">{{ userName }}</p>
            <p class="text-center text-gray-600 mb-4">has successfully completed</p>
            <p class="text-center text-xl font-bold text-secondary-800 mb-6">{{ trainingProgram.name }}</p>
            
            <div v-if="certificate.score" class="text-center mb-6">
              <span class="badge bg-primary-100 text-primary-800 text-lg px-4 py-1">
                Score: {{ certificate.score }}%
              </span>
            </div>

            <div class="grid grid-cols-2 gap-4 mt-8">
              <div class="text-center">
                <p class="text-sm text-gray-500">Issued On</p>
                <p class="font-medium">{{ formattedDate(certificate.issued_at) }}</p>
              </div>
              <div class="text-center">
                <p class="text-sm text-gray-500">Valid Until</p>
                <p class="font-medium">{{ formattedDate(certificate.expires_at) }}</p>
              </div>
            </div>

            <div class="mt-8 text-center">
              <p class="text-sm text-gray-500 mb-2">Verification Code</p>
              <p class="font-mono text-xs bg-gray-100 p-2 rounded">{{ certificate.verification_code }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- PDF Actions -->
      <div class="pdf-actions mt-8">
        <div v-if="isPdfProcessing" class="flex items-center justify-center space-x-2 text-primary-600 mb-4">
          <div class="loading-spinner w-5 h-5"></div>
          <span>Generating PDF certificate...</span>
        </div>

        <div v-if="isPdfFailed" class="text-red-600 mb-4">
          <p>Failed to generate PDF. Please try regenerating.</p>
        </div>

        <div class="flex flex-wrap gap-4 justify-center">
          <button
            @click="handleDownload"
            class="btn btn-primary"
            :disabled="!isPdfReady"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            Download Certificate
          </button>

          <button
            @click="handleRegenerate"
            class="btn btn-secondary"
            :disabled="isPdfProcessing"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            Regenerate PDF
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.certificate-container {
  @apply max-w-2xl mx-auto;
}

.certificate-preview {
  @apply border-2 border-gray-200 bg-white;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
}

.certificate-content {
  @apply py-8 px-4;
}

.badge {
  @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}
</style>