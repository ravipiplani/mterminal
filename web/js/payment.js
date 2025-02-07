function openRazorpay(optionsStr) {
    let options = JSON.parse(optionsStr);
    options.handler = function(response) {
        razorpayCallback(response.razorpay_order_id, response.razorpay_payment_id, response.razorpay_signature);
    }
    options.modal.ondismiss = function () {
        razorpayModalDismissed();
    }
    let rzp1 = new Razorpay(options);
    rzp1.open();
}