# Add service
There are three types of main services
  - Hospitality
  - Events
  - Professional Trainer

There are three types of role types
  - Freelancer
  - Business
  - Productive families

The sub categories and options will be changed based on the three types


# Hospitality
  A. Freelancer:
    • Waiter
    • Waitress
    • Barista (Hot & Cold)
    • Juice Maker
    • Sandwich Maker
    • Burger Maker
    • Shawarma Maker
    • Chef
      • International Chef
      • Emirates Chef
      • Indian Chef 
      • Pastry chef
      • Sous Chef
      • Chinese Chef
      • Japanese Chef
      • Italian Chef
      • Philippine Chef
    • Arabic tea & Coffee Maker (Hot & cold)
    • Coffee Serving person
    • Live Cooking chef
    • Executive Chef
    • Cook
    • Food and Beverage Manager
    • Kitchen Manager
    • Housekeeper
    • Baker
    • Catering Manager
    • Beverages Server
    • Butcher
    • Banquet Server
    • Head waiter
    • Kitchen assistant
    • Cake Decorator
  B. Companies (Business)
    - CATERING :
      - Buffet
        Indian Buffet 
        International Buffet
        Emirate Buffet
        Chines Buffet
        Italian Buffet
        Japanese Buffet
        Thai Buffet
        Arabic Buffet
        Filipino Buffet
        Mini Bites Buffet 

      - Live cooking
        Pastry Station
        Burger Station
        Pizza Station
        Shawarma Station
    
    - Outdoor Cafe Kiosk
      - Outdoor Mobile Food Truck
      - Mobile Coffee car/Mini Car
      - Coffee Cart
      - Outdoor Coffee kiosk 
      - Coffee Hospitality Provider
  C. Productive families
    - Private Catering Buffet Services
    - Small Bites & canape Appetizers Buffet 
    - Coffee Hospitality Service
# Events
  A. Freelancer
    • Presenter /MC (emcee)
    • Counter Service assistant
    • Wedding planner
    • Event Planner
    • Host
    • Hostess
    • Events Manager
    • Executive Conference Manager
    • Executive Meeting Manager
    • Meeting and Convention Planner
    • Meeting Coordinator
    • Meeting Manager
    • Meeting Planner
    • Meeting Specialist
    • Special Events Manager
    • Wedding coordinator
    • Magic Man/Woman
    • Photographers
    • Butler
    • Housekeeper
    • Event Volunteer
    • Stage Show
    • Flower designer
    • Flower assistant
    • Performer
    • Theme & Design Provider
    • Security
    • Truck driver
    • forkLift truck driver
    • Operation Manager
    • HSE Manager
    • Head Florist
    • Events Coordinator
    • Event Promoter
    • Store In-charge
    • Office boy/cleaner
    • Cleaner
    • Clown
    • Artists
    • Sculpture
    • Painters
    • Graphic Designers
    • Textile artists
    • Painters
    • Cinematographers.
    • Illustrations
    • Marketing coordinator
    • Director of event Marketing
    • Catering Manager
  B. Business
    - Venues 
      - Hotel venue
      - Restaurant venue
      - Mall Venue
      - Exhibition venue
      - Café venue 
      - Farm venue 
      - Land venue 
    - Videographer/Photographer company
      - Event Videographer
      - Exhibition Photographer
      - Food photographer
      - Event photographer
      - Party photographer
      - Kids photographer
    - Cultural Cloths Rentals
    - Stage Performers company
    - Flower arrangements company
    - Birthday Planners
    - Wedding Planner
    - Accessories Rental Company
    - LED Light indoor/outdoor Rental
    - Furniture Event Rentals
    - Stage Event Rentals 
    - Gifts Company
    - Tables & chairs Rentals
    - Exhibition Furniture Rentals
    - Screens and LED Display Rentals 
    - Lighting & Visual Company 
    - Theme & Designs companies
    - Photo Booths Rentals 
    - Inflatable Bouncy & Slides
    - Tents Rentals
    - Perfume Provider 
    - Party Planner
    - Centerpieces Rentals company
    - Kids Theme & Design
    - Presenter /MC (emcee)
    - Stage performers
    - Magician 
  C. Productive Families
    • Wedding Planner
    • Party Planner
    • Booth Rentals
    • Food Mobile & Station Truck Rentals
    • Accessories Rentals
    • Furniture Rentals
    • Traditional & Cultural Items Rentals
    • Gifts & hand made
    • Rental Themes
    • Audio /Screens/ Visual /Lights Rentals
    • Exhibition Photographer
    • Food photographer
    • Event photographer
    • Party photographer
    • Cultural Cloths Rentals
    • Mobile Coffee car/Mini Car
    • Coffee Cart
# Professional Training
  A. Freelancer
    • Housekeeper Trainer
    • Butler Trainer
    • Cooking Training for Resident 
    • Waiter/Waitress Training 
    • Servant Training
    • Arabic Coffee Maker Trainer
    • Juice Maker Trainer
    • Barista Trainer
    • Sandwich Maker Trainer
    • Pastry Maker Trainer
    • Sous Maker Trainer
    • Burger Maker Trainer
    • Arabic Serving Hospitality Trainer
    • Cake Decorator Trainer
    • Biscuits & Sweets Trainer 
    • Hotel Housekeeper Trainer
    • Emirate Cook Trainer
    • Flower design/arrangement Training
    • Etiquette training
    • Host Training
    • Hostess Training 
    • Event Volunteer Training
    • Buffet arrangements Training
    • Table arrangements Training
  B. Business
    • Housekeeper Trainer
    • Butler Trainer
    • Cooking Training for Resident 
    • Waiter/Waitress Training 
    • Servant Training
    • Arabic Coffee Maker Trainer
    • Juice Maker Trainer
    • Barista Trainer
    • Sandwich Maker Trainer
    • Pastry Maker Trainer
    • Sous Maker Trainer
    • Burger Maker Trainer
    • Hospitality Protocol Trainer
    • Arabic Serving Hospitality Trainer
    • Cake Decorator Trainer
    • Food Presentation Trainer
    • Biscuits & Sweets Trainer 
    • Hotel Housekeeper Trainer
    • Emirate Cook Trainer
    • Flower design/arrangement Training
    • Etiquette training
    • Host Training 
    • Hostess Training
    • Event Volunteer Training
    • Buffet arrangements Training
    • Table arrangements Training
  C. Productive Families
    • Housekeeper Trainer
    • Butler Trainer
    • Cooking Training for Resident 
    • Waiter/Waitress Training 
    • Servant Training
    • Arabic Coffee Maker Trainer
    • Juice Maker Trainer
    • Barista Trainer
    • Sandwich Maker Trainer
    • Pastry Maker Trainer
    • Sous Maker Trainer
    • Burger Maker Trainer
    • Hospitality Protocol Trainer
    • Arabic Serving Hospitality Trainer
    • Cake Decorator Trainer
    • Food Presentation Trainer
    • Biscuits & Sweets Trainer 
    • Hotel Housekeeper Trainer
    • Emirate Cook Trainer
    • Flower design/arrangement Training
    • Etiquette training
    • Host Training 
    • Hostess Training
    • Event Volunteer Training
    • Buffet arrangements Training
    • Table arrangements Training


Also, there is now a architectural changes now the field data come from the backend instead of hardcoded them.


GET: api/services/category-master/dropdown?service_type_name=Hospitality&role_name=Business&service_as_name=Catering&sub_service_name=Buffet


Output:
{
    "success": true,
    "message": "sub_sub_service_name dropdown retrieved successfully.",
    "data": {
        "level": "sub_sub_service_name",
        "items": [
            "Arabic Buffet",
            "Chines Buffet",
            "Emiratie Buffet",
            "Filipino Buffet",
            "Indian Buffet",
            "International Buffet",
            "Italian Buffet",
            "Japanese Buffet",
            "Mini Bites Buffet",
            "Thai Buffet"
        ],
        "has_next": true
    }
}


Now update the add_service file and controllers.
