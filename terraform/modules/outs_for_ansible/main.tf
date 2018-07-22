data "template_file" "user_data" {
  template = "${file("${path.module}/terraform_to_ansible.tpl")}"

  vars {
    db_ext_ip  = "${var.db_external_ip}"
    app_ext_ip = "${var.app_external_ip}"
  }
}

resource "local_file" "file" {
  content  = "${data.template_file.user_data.rendered}"
  filename = "${path.module}/outs.json"
}
