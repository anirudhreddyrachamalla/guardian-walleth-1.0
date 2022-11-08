/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{js,jsx,ts,tsx}",],
  theme: {
    extend: {
      colors:{
        "backgroung-color":"var(--background-color)",
        "background-color-1":"var(--background-color-1)",
        "font-color":"var(--font-color)",
        "font-color-1":"var(--font-color-1)",
        "success-btn":"var(--success-btn)",
        "cancel-btn":"var(--cancel-btn)"
      }
    },
  },
  plugins: [],
}
