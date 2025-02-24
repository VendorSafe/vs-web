# Seeder config file to store email addresses and passwords for demo seeded users

SEEDER_CONFIG = {
  admin: {
    email: "jcsarda+admin@gmail.com",
    password: "password123",
    first_name: "John",
    last_name: "Sarda",
    time_zone: "America/Los_Angeles",
    locale: "en"
  },
  customers: [
    {
      email: "jcsarda+customer1@gmail.com",
      password: "password123",
      first_name: "Alice",
      last_name: "Johnson",
      company: "Pacific Northwest Energy",
      locations: ["Seattle HQ", "Portland Branch"],
      training_programs: [
        {
          name: "Safety Protocol 101",
          description: "Comprehensive safety training covering basic protocols and procedures for energy industry workers."
        },
        {
          name: "Environmental Compliance",
          description: "Training on environmental regulations and compliance requirements for energy facilities."
        }
      ]
    },
    {
      email: "jcsarda+customer2@gmail.com",
      password: "password123",
      first_name: "Bob",
      last_name: "Smith",
      company: "Mountain Power Co",
      locations: ["Denver Main"],
      training_programs: [
        {
          name: "Basic Safety Training",
          description: "Essential safety training for all Mountain Power Co employees."
        }
      ]
    },
    {
      email: "jcsarda+customer3@gmail.com",
      password: "password123",
      first_name: "Carol",
      last_name: "Williams",
      company: "Western Grid Solutions",
      locations: ["San Francisco HQ", "Los Angeles Office", "San Diego Branch"],
      training_programs: [
        {
          name: "Grid Management",
          description: "Advanced training on grid management systems and protocols."
        },
        {
          name: "Emergency Response",
          description: "Procedures and protocols for handling grid emergencies."
        },
        {
          name: "Customer Service",
          description: "Training for customer service representatives on handling grid-related inquiries."
        }
      ]
    },
    {
      email: "jcsarda+customer4@gmail.com",
      password: "password123",
      first_name: "David",
      last_name: "Brown",
      company: "Desert Power LLC",
      locations: ["Phoenix Main"],
      training_programs: [
        {
          name: "Heat Safety Protocol",
          description: "Safety procedures for working in high-temperature environments."
        }
      ]
    },
    {
      email: "jcsarda+customer5@gmail.com",
      password: "password123",
      first_name: "Emma",
      last_name: "Davis",
      company: "Cascade Energy Group",
      locations: ["Seattle Office", "Spokane Branch"],
      training_programs: [
        {
          name: "Winter Operations",
          description: "Procedures for maintaining energy operations during winter conditions."
        },
        {
          name: "Equipment Safety",
          description: "Safety protocols for operating and maintaining energy equipment."
        }
      ]
    }
  ],
  vendors: [
    {
      email: "jcsarda+vendor1@gmail.com",
      password: "password123",
      first_name: "Frank",
      last_name: "Miller",
      company: "SafetyFirst Training Co",
      serves_customers: ["Pacific Northwest Energy", "Western Grid Solutions"],
      locations: ["Seattle", "Portland"]
    },
    {
      email: "jcsarda+vendor2@gmail.com",
      password: "password123",
      first_name: "Grace",
      last_name: "Wilson",
      company: "PowerGrid Educators",
      serves_customers: ["Mountain Power Co"],
      locations: ["Denver"]
    },
    {
      email: "jcsarda+vendor3@gmail.com",
      password: "password123",
      first_name: "Henry",
      last_name: "Taylor",
      company: "Grid Safety Solutions",
      serves_customers: ["Western Grid Solutions", "Desert Power LLC"],
      locations: ["Los Angeles", "Phoenix"]
    },
    {
      email: "jcsarda+vendor4@gmail.com",
      password: "password123",
      first_name: "Isabel",
      last_name: "Anderson",
      company: "Compliance Training Inc",
      serves_customers: ["Cascade Energy Group"],
      locations: ["Seattle", "Spokane"]
    },
    {
      email: "jcsarda+vendor5@gmail.com",
      password: "password123",
      first_name: "James",
      last_name: "Thomas",
      company: "Safety Protocol Experts",
      serves_customers: ["Pacific Northwest Energy", "Mountain Power Co"],
      locations: ["Portland", "Denver"]
    }
  ],
  employees: [
    {
      email: "jcsarda+employee1@gmail.com",
      password: "password123",
      first_name: "Karen",
      last_name: "Martinez",
      role: "Safety Manager",
      company: "Pacific Northwest Energy",
      location: "Seattle HQ"
    },
    {
      email: "jcsarda+employee2@gmail.com",
      password: "password123",
      first_name: "Liam",
      last_name: "Garcia",
      role: "Operations Supervisor",
      company: "Western Grid Solutions",
      location: "San Francisco HQ"
    },
    {
      email: "jcsarda+employee3@gmail.com",
      password: "password123",
      first_name: "Maria",
      last_name: "Rodriguez",
      role: "Training Coordinator",
      company: "Mountain Power Co",
      location: "Denver Main"
    },
    {
      email: "jcsarda+employee4@gmail.com",
      password: "password123",
      first_name: "Nathan",
      last_name: "Lee",
      role: "Safety Inspector",
      company: "Desert Power LLC",
      location: "Phoenix Main"
    },
    {
      email: "jcsarda+employee5@gmail.com",
      password: "password123",
      first_name: "Olivia",
      last_name: "King",
      role: "Compliance Officer",
      company: "Cascade Energy Group",
      location: "Seattle Office"
    }
  ],
  trainees: [
    {
      email: "jcsarda+trainee1@gmail.com",
      password: "password123",
      first_name: "Paul",
      last_name: "Clark",
      company: "Pacific Northwest Energy",
      location: "Portland Branch",
      assigned_programs: ["Safety Protocol 101"]
    },
    {
      email: "jcsarda+trainee2@gmail.com",
      password: "password123",
      first_name: "Quinn",
      last_name: "Adams",
      company: "Western Grid Solutions",
      location: "Los Angeles Office",
      assigned_programs: ["Grid Management", "Emergency Response"]
    },
    {
      email: "jcsarda+trainee3@gmail.com",
      password: "password123",
      first_name: "Rachel",
      last_name: "Turner",
      company: "Mountain Power Co",
      location: "Denver Main",
      assigned_programs: ["Basic Safety Training"]
    },
    {
      email: "jcsarda+trainee4@gmail.com",
      password: "password123",
      first_name: "Steve",
      last_name: "White",
      company: "Desert Power LLC",
      location: "Phoenix Main",
      assigned_programs: ["Heat Safety Protocol"]
    },
    {
      email: "jcsarda+trainee5@gmail.com",
      password: "password123",
      first_name: "Tara",
      last_name: "Brown",
      company: "Cascade Energy Group",
      location: "Spokane Branch",
      assigned_programs: ["Winter Operations"]
    }
  ]
}
