document.addEventListener("DOMContentLoaded", function () {
    const form = document.querySelector("form");
    const nameInput = document.querySelector("#Name");
    const displayOrderInput = document.querySelector("#DisplayOrder");
    const validationSummary = document.querySelector("#Validation");
    console.log(validationSummary);
    

    form.addEventListener("submit", function (event) {
        let errors = [];

        if (nameInput.value === displayOrderInput.value) {
            errors.push("Name and Display Order cannot be the same.");
        }

        if (errors.length > 0) {
            event.preventDefault(); // Prevent form submission
            displayErrors(errors);
        }
    });

    function displayErrors(errors) {
   
        errors.forEach(function (error) {
            const errorElement = document.createElement("div");
            errorElement.className = "text-danger";
            errorElement.innerText = error;
            validationSummary.appendChild(errorElement);
        });
    }
});