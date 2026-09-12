export const ITEM_CATEGORY_GROUPS = [
  {label:"Clothing",options:["Jacket & Coat","Hoodie & Sweater","Shirt & Top","Pants & Shorts","School Uniform","Hat & Cap","Gloves & Scarf","Shoes & Boots"]},
  {label:"Bags",options:["School Bag & Backpack","Lunch Box & Lunch Bag","Sports Bag","Handbag & Purse","Pencil Case","Wallet & Card Holder"]},
  {label:"Drink & Food",options:["Water Bottle","Food Container","Thermos & Travel Mug"]},
  {label:"School Supplies",options:["Notebook & Binder","Book & Textbook","Stationery","Calculator","Art Supplies","Musical Instrument"]},
  {label:"Technology",options:["Phone","Tablet & E-reader","Laptop & Chromebook","Headphones & Earbuds","Smartwatch & Watch","Charger & Cable","Camera"]},
  {label:"Sports & Personal",options:["Sports Equipment","Jewelry","Glasses & Sunglasses","Keys","Umbrella","Toy & Game","Medical Item","Other"]},
] as const;

export const ITEM_CATEGORIES = ITEM_CATEGORY_GROUPS.flatMap(group=>group.options);

export const ITEM_COLORS = [
  "Black","White","Gray","Silver","Red","Orange","Yellow","Green","Blue","Navy","Purple","Pink","Brown","Beige","Gold","Teal","Clear","Multicolor","Other",
] as const;

export const SCHOOL_LOCATIONS = [
  "Main Office","Front Desk","Reception","Student Services","Nurse's Office","Counseling Office","Principal's Office","Attendance Office","Security Desk",
  "Classroom","Kindergarten Classroom","Elementary Classroom","Middle School Classroom","High School Classroom","Science Lab","Computer Lab","Art Room","Music Room","Library","Media Center",
  "Cafeteria","Lunch Area","Kitchen","Gym","Locker Room","Fitness Room","Auditorium","Theater","Stage","Multipurpose Room",
  "Playground","Sports Field","Football Field","Soccer Field","Baseball Field","Basketball Court","Tennis Court","Track","Swimming Pool","School Garden",
  "Hallway","Stairwell","Elevator","Restroom","Student Locker Area","Staff Room","School Store","Bus Loop","Bus","Car Pickup Area","Parking Lot","Bike Rack","Main Entrance","Side Entrance","Courtyard","Near the School Gate","Other",
] as const;

export const COLOR_SWATCHES:Record<string,string>={Black:"#1e293b",White:"#ffffff",Gray:"#94a3b8",Silver:"#cbd5e1",Red:"#ef4444",Orange:"#f97316",Yellow:"#facc15",Green:"#22c55e",Blue:"#3b82f6",Navy:"#1e3a8a",Purple:"#8b5cf6",Pink:"#ec4899",Brown:"#92400e",Beige:"#d6c5a3",Gold:"#d4a017",Teal:"#14b8a6",Clear:"#e0f2fe",Multicolor:"linear-gradient(135deg,#ef4444 0 25%,#facc15 25% 50%,#22c55e 50% 75%,#3b82f6 75%)",Other:"#e2e8f0"};
