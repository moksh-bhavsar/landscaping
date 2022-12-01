class LocalUser {
  String firstName;
  String lastName;
  String bio;
  String street;
  String city;
  String country;
  String isWorker;
  double rating;
  double reviews;
  String business;
  double credits;
  LocalUser(this.firstName, this.lastName, this.bio, this.street, this.city,
      this.country)
      : isWorker = 'false',
        rating = 0,
        reviews = 0,
        business = '',
        credits = 100;

  Map<String, dynamic> getDataMap() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "bio": bio,
      "address": {"Street": street, "City": city, "Country": country},
      "isWorker": isWorker,
      "rating": rating,
      "reviews": reviews,
      "credits": credits,
    };
  }
}
