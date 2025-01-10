# VendorSafe.app

 # Here is a list of all of my npm packages:

# Below is

```
   "build": "THEME=\"light\" node esbuild.config.js",
    "build:css": "bin/link; THEME=\"light\" yarn build --reload; yarn light:build:css; yarn light:build:mailer:css",
    "light:build:css": "THEME=\"light\" NODE_PATH=./node_modules tailwindcss -c tailwind.config.js -i ./app/assets/stylesheets/application.css -o ./app/assets/builds/application.light.css --postcss ./postcss.config.js",
    "light:build:mailer:css": "THEME=\"light\" NODE_PATH=./node_modules tailwindcss -c /Users/sarda/.asdf/installs/ruby/3.3.6/lib/ruby/gems/3.3.0/gems/bullet_train-themes-light-1.12.0/tailwind.mailer.light.config.js -i /Users/sarda/Projects/vs-web/app/assets/stylesheets/light.tailwind.css -o ./app/assets/builds/application.mailer.light.css --postcss /Users/sarda/.asdf/installs/ruby/3.3.6/lib/ruby/gems/3.3.0/gems/bullet_train-themes-light-1.12.0/tailwind.mailer.light.config.js",
    "concat-bullet-train-readmes": "node scripts/concat-readmes.js",
    "bs": "browser-sync start --config browser-sync.config.js"

```


# Udoras Sitmap Outline

Confirm each pagg / feature is at least considred

*   [ ] [Home](home.md)

    *   [ ] Admin (admin.md)
        *   [ ] Customers (admin_customers.md)
            *   [ ] Create Customer (admin_create_customer.md)
            *   [ ] Edit Customer (admin_edit_customer.md)
            *   [ ] Delete Customer (admin_delete_customer.md)
        *   [ ] Vendors (admin_vendors.md)
            *   [ ] Create Vendor (admin_create_vendor.md)
            *   [ ] Edit Vendor (admin_edit_vendor.md)
        *   [ ] Employees (admin_employees.md)
            *   [ ] Create Employee (admin_create_employee.md)
            *   [ ] Edit Employee (admin_edit_employee.md)
        *   [ ] Trainings (admin_trainings.md)
            *   [ ] Edit Training Info (admin_edit_training_info.md)
            *   [ ] View Presentation (1) (admin_view_presentation_1.md)
            *   [ ] View Presentation (2) (admin_view_presentation_2.md)
            *   [ ] View Presentation (3) (admin_view_presentation_3.md)
            *   [ ] Delete Training (admin_delete_training.md)
            *   [ ] Edit Training Presentation (admin_edit_training_presentation.md)
            *   [ ] Create Training (admin_create_training.md)
            *   [ ] Add Presentation (admin_add_presentation.md)
        *   [ ] Payments (admin_payments.md)
        *   [ ] Reports (admin_reports.md)
            *   [ ] Download PDF (admin_download_pdf.md)
    *   [ ] Customer (customer.md)
        *   [ ] My Profile (customer_my_profile.md)
        *   [ ] Vendors (customer_vendors.md)
        *   [ ] Training List (customer_training_list.md)
        *   [ ] View Training Info (customer_view_training_info.md)
        *   [ ] View Presentation (1) (customer_view_presentation_1.md)
        *   [ ] View Presentation (2) (customer_view_presentation_2.md)
        *   [ ] View Presentation (3) (customer_view_presentation_3.md)
        *   [ ] Send Training Request (customer_send_training_request.md)
    *   [ ] Vendor (vendor.md)
        *   [ ] My Profile (vendor_my_profile.md)
        *   [ ] Training Requests (vendor_training_requests.md)
        *   [ ] Send Training Info (vendor_send_training_info.md)
        *   [ ] Training Info (vendor_training_info.md)
        *   [ ] Pool for Training (vendor_pool_for_training.md)
        *   [ ] Download Certificate (vendor_download_certificate.md)
        *   [ ] Shows Certificate with email (vendor_shows_certificate_with_email.md)
    *   [ ] Employee (employee.md)
        *   [ ] Training Requests (employee_training_requests.md)
        *   [ ] Training Info (employee_training_info.md)
        *   [ ] Pass Training (1) (employee_pass_training_1.md)
        *   [ ] Pass Training (2) (employee_pass_training_2.md)
        *   [ ] Pass Training (3) (employee_pass_training_3.md)
        *   [ ] Training Results (employee_training_results.md)
        *   [ ] View Certificate (employee_view_certificate.md)
    *   [ ] Click here to go back to Home Page (click_here_to_go_back_to_home_page.md) *This is likely redundant*