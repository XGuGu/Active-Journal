#ActiveJournal

ActiveJournal is a custom mapping library developed in Ruby. It is inspired by Active Record. The library uses object-oriented programming and meta-programming to abstract SQL queries which allows the developer have a more intuitive database access.

##Learning Goals

* Know when to write class methods and when to write instance methods
* Know how to use define_method inside a class method to add instance methods
* Be able to create a generic SQLObject class that abstracts table-specific logic away
* Understand how ActiveRecord interfaces with the database
* Be able to write generic query methods that any class inheriting from SQLObject can use (e.g., all, where)

##Features
* SQLObject part will interact with the database, with methods including: ::all, ::find, #insert, #update, #save
* Searchable part will add the ability to search using ::where.
* Associatable part will handle the module association.
