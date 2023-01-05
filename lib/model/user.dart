class User {
  String? id;
  String? email;
  String? name;
  String? phone;
  String? address;
  String? regdate;

  User(
      {this.id, this.email, this.name, this.phone, this.address, this.regdate});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    address = json['address'];
    regdate = json['regdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = this.email;
    data['name'] = this.name;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['regdate'] = regdate;
    return data;
  }
}
