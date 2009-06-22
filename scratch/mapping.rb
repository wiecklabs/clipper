#! /usr/bin/env jruby

# Mappings need to be awesome. Here's some basic requirements:
#
# Your Domain Model should type-cast. It's not PORO, it's practical. The
# Domain Model must be functional outside of the scope of any Repository,
# specifically when creating a new instance. This means that type-casting of
# model attributes during assignment can not
# happen in the mappings.
#
# Types are broken up into two categories: Attribute Types and Repository Types.
# Attribute Types define the Type for an attribute value. eg: The "object-side"
# of the mapping equation. Repository Types define the Type for a value in the
# store. eg: Postgres::VarChar.
#
# You should be able to easily define custom Attribute Types.
#
# Type-casting between Repository Types and Attribute Types is handled by a
# Repository specific TypeMap which defines the "signature" of a type-cast
# operation. A type-cast-signature is made up of the Attribute Type, the
# Repository Type(s), and routines to convert to and from the types. ie:
#   #<Signature: Point, [Postgres::Integer, Postgres::Integer]>
# A given attribute-mapping is compared to the available TypeMap signatures.
# Once an appropriate signature is found, the values can be converted to/from
# the target types.
#
# It's important to note that the TypeMap is used for type-casting only, not
# specific attribute mapping. In other words you might have the following
# signatures available:
#   #<Signature: String, [String]>
#   #<Signature: String, [Integer]>
#   #<Signature: Integer, [String]>
#   #<Signature: Integer, [Integer]>
# Clearly if you only knew the Attribute Type was a String, the appropriate
# Signature to use would still be ambiguous. This is because "Person#age<String>"
# might map to "people.age INT" but "Person#name<String>" might map to
# "people.name VARCHAR". In other words there is not a 1:1 relationship between
# Attribute Types and Repository Types. There is no default, or fixed mapping
# between types. Every supported Attribute Type for a given Repository must be
# explicitly "bridged" with a corresponding type-cast-signature in the TypeMap
# for every Repository Type it can be cast from/to.
#
# Yes, it will be a fair amount of signatures involved in creating a
# comprehensive TypeMap for a given Repository, but it's very simple work that
# can be done easily, and as-needed.
#
# Because Attribute Types don't have to be extended for type-casting purposes,
# Clipper specific classes for types already available in Ruby don't have to
# be defined. A String can simply be a String, a DateTime a DateTime, etc.
# The same is true for Repository Types. This means that many signatures in
# the TypeMap can be inherited from an abstract set to minimize the work of
# implementing a new Adapter.
#
# Further, Query operations, Materialization, ResultSet mapping, etc can all
# be abstracted out of the Adapters. The Repository specific responsibilities
# then will be defining a Syntax internal to the Adapter that will transform the
# provided Query into a compatible command, and returning a ResultSet.
#
# Testing can then be done in-memory, supporting as much of, or as little of
# the O/RM features as desired.
#
# The Query will be used by the Loader to materialize an object-graph based on
# oridinals in the ResultSet. The only requirement for an adapter is that 
