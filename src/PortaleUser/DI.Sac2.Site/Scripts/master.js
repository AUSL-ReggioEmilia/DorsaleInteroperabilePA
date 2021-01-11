function extendedValidatorUpdateDisplay(obj) {
  if (typeof originalValidatorUpdateDisplay === "function") {
    originalValidatorUpdateDisplay(obj);
  }
  var control = document.getElementById(obj.controltovalidate);
  if (control) {
   var isValid = true;
   for (var i = 0; i < control.Validators.length; i += 1) {
   if (!control.Validators[i].isvalid) {
    isValid = false;
     break;
   }
  }
  if (isValid) {
   $(control).closest(".form-group").removeClass("has-error");
  } else {
   $(control).closest(".form-group").addClass("has-error");
   }
  }
}
var originalValidatorUpdateDisplay = window.ValidatorUpdateDisplay;
window.ValidatorUpdateDisplay = extendedValidatorUpdateDisplay;