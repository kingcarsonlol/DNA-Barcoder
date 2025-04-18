<script setup>
import html2canvas from "html2canvas";

const props = defineProps(["dnaCode", "options"]);
const barcodeElement = ref();

const barcodeColors = computed(() => {
  return (props.dnaCode || "")
    .split("")
    .map((nucleotide) => props.options.colors[nucleotide]);
});

async function downloadBarcode() {
  if (!(barcodeElement.value instanceof HTMLElement)) {
    console.error("barcodeElement.value is not a valid HTML element");
    return;
  }
  try {
    // Force any pending renders to complete
    await nextTick();
    
    // Create a temporary container with the exact same dimensions
    const tempContainer = document.createElement("div");
    tempContainer.style.position = "absolute";
    tempContainer.style.left = "-9999px";
    tempContainer.style.top = "0";
    
    // Explicitly use the same width as the original container
    tempContainer.style.width = props.options.width + "vw";
    tempContainer.style.height = barcodeElement.value.offsetHeight + "px";
    tempContainer.style.backgroundColor = "transparent";
    
    // Create the barcode in the temporary container with explicit spacing
    for (const color of barcodeColors.value) {
      const bar = document.createElement("div");
      bar.style.display = "inline-block";
      bar.style.width = "1px";
      bar.style.height = "40px";
      bar.style.marginRight = "1px";
      bar.style.backgroundColor = color;
      tempContainer.appendChild(bar);
    }
    
    document.body.appendChild(tempContainer);
    
    // Generate canvas from the temporary element
    const canvas = await html2canvas(tempContainer, {
      backgroundColor: null,
      scale: 3,
      logging: false,
      useCORS: true,
      width: tempContainer.offsetWidth,
      height: tempContainer.offsetHeight
    });
    
    // Convert canvas to image and download
    const image = canvas.toDataURL("image/png");
    const link = document.createElement("a");
    link.href = image;
    link.download = "dna-barcode.png";
    link.click();
    
    // Clean up
    document.body.removeChild(tempContainer);
  } catch (error) {
    console.error("Error generating barcode image:", error);
  }
}
</script>

<template>
  <div class="flex flex-col justify-center items-center">
    <button
      v-if="props.dnaCode"
      class="mt-5 bg-blue-500 rounded-2xl p-2 text-md text-white hover:bg-blue-700"
      @click="downloadBarcode"
    >
      Download DNA Barcode
    </button>
    <div
      ref="barcodeElement"
      class="mt-5"
      :style="{ width: props.options.width + 'vw' }"
    >
      <div
        v-for="(color, index) in barcodeColors"
        :key="index"
        :style="{ backgroundColor: color }"
        class="w-1 h-10 mr-[1px] inline-block mb-[-3.5px]"
      />
    </div>
  </div>
</template>
