require "test_helper"

class TestContact < Test::Unit::TestCase
  def test_new_from_data
    data = {'first_name' => 'John', 'last_name' => 'Smith', 'email' => nil, 'phone' => nil}
    assert contact = Cloudsponge::Contact.new(data)
    assert_equal data['first_name'], contact.first_name
    assert_equal data['last_name'], contact.last_name
    assert_equal "#{data['first_name']} #{data['last_name']}", contact.name
    assert_equal nil, contact.email
    assert_equal nil, contact.phone

    data = {'first_name' => 'John', 'last_name' => 'Smith', 'email' => [{'address' => 'joe@example.com'}], 'phone' => [{'number' => '555-1234'}]}
    assert contact = Cloudsponge::Contact.new(data)
    assert_equal data['first_name'], contact.first_name
    assert_equal data['last_name'], contact.last_name
    assert_equal "#{data['first_name']} #{data['last_name']}", contact.name
    assert_equal 'joe@example.com', contact.email
    assert_equal '555-1234'       , contact.phone
  end
  
  def test_from_all_possible_attributes
    data = { "first_name" =>"Abigale Kirlin",
             "last_name"  =>"Kautzer",
             "phone"=>
              [{"number" => "1-274-714-0088", "type" => "Business fax"},
               {"number" => "(719) 110-7733 x682", "type" => "Home"},
               {"number" => "(425) 385-9484 x8245", "type" => "Other"},
               {"number" => "906.146.3215", "type" => "Mobile"},
               {"number" => "935.208.5960", "type" => "Primary"},
               {"number" => "528.604.8156 x570", "type" => "Home fax"},
               {"number" => "119.297.9772 x184", "type" => "Business"},
               {"number" => "(712) 636-9651 x6347", "type" => "Other fax"}],
             "email"=>
              [{"address"=>"cesar@kub.info", "type"=>"E-mail 1"},
               {"address"=>"germaine.gorczany@stroman.org", "type"=>"E-mail 2"},
               {"address"=>"onie_pfannerstill@herzog.co", "type"=>"E-mail 3"}],
             "address"=>
              [{"type"=>"Home",
                "street"=>"4535 Bednar Trace ",
                "city"=>"Turnermouth",
                "region"=>"Wisconsin",
                "postal_code"=>"45589-5220",
                "country"=>"Ghana"},
               {"type"=>"Business",
                "street"=>"3000 White Mill ",
                "city"=>"Dachburgh",
                "region"=>"South Dakota",
                "postal_code"=>"38529-1507",
                "country"=>"Sweden"},
               {"type"=>"Other",
                "street"=>"5997 Wolf Underpass ",
                "city"=>"Port Tyrese",
                "region"=>"Colorado",
                "postal_code"=>"32992-0271",
                "country"=>"Tanzania"}],
             "groups"=>[],
             "dob"=>"1994-08-27",
             "birthday"=>"08-27",
             "companies"=>["O'Conner Inc"],
             "title"=> "Mr.",
             "job_title"=>"District Integration Administrator",
             "photos"=>[],
             "locations"=>[]}
  
    assert contact = Cloudsponge::Contact.new(data)
    assert_equal data['first_name'], contact.first_name
    assert_equal data['last_name'], contact.last_name
    assert_equal "#{data['first_name']} #{data['last_name']}", contact.name
    
    assert_equal 'cesar@kub.info', contact.email
    assert_equal '1-274-714-0088', contact.phone
    assert_equal '4535 Bednar Trace  Turnermouth Wisconsin', contact.address
    
    assert_equal Array, contact.emails.class
    assert_equal Array, contact.phones.class
    assert_equal Array, contact.addresses.class

    assert_equal data["groups"]   , contact.groups
    assert_equal data["dob"]      , contact.dob
    assert_equal data["birthday"] , contact.birthday
    assert_equal data["companies"], contact.companies
    assert_equal data["title"]    , contact.title
    assert_equal data["job_title"], contact.job_title
    assert_equal data["photos"]   , contact.photos
    assert_equal data["locations"], contact.locations
  end
end
