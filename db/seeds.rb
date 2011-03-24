require 'csv'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

# Categories
categories = [
  { :name => "Programming Langauge", :description => "Building blogs of websites, programming languages are the basis for all other choices made in development of a site.", :keyword => "language" },
  { :name => "Framework", :description => "System to build on.", :keyword => "framework" },
  { :name => "Service", :description => "Service used. Usually this will mean going to their website to actually do something. Often used together with an API.", :keyword => "service" },
  { :name => "API", :description => "Application Programming interface, or service.", :keyword => "api" },
  { :name => "Library", :description => "Libraries are the building blocks for creating both other libraries and websites.", :keyword => "library" },
  { :name => "Datastore", :description => "An organized database or data store.", :keyword => "database" },
  { :name => "Website", :description => "The site itself is used.", :keyword => "website" },
  { :name => "CMS", :description => "Content Management System", :keyword => "cms" },
  { :name => "Application", :description => "Installable applications", :keyword => "application" },
  { :name => "Platform", :description => "Web, application or platform host.", :keyword => "platform" },
  { :name => "Testing", :description => "Components related to testing an application.", :keyword => "test" },
  { :name => "Standard", :description => "This tool has multiple implementations that share this same name."}
]

categories.each do |attributes|
  Category.find_or_initialize_by_keyword(attributes[:keyword]).tap do |category|
    category.name = attributes[:name]
    category.description = attributes[:description]
    category.save!
  end
end
puts "Categories complete..."

Invite.create({ :code => "friends", :max_count => 100 })
puts "Invites complete..."



tools = [
  # C
  { :name => "C", :url => "http://en.wikipedia.org/wiki/C_(programming_language)", :description => "C is a general-purpose computer programming language developed for use with the Unix operating system.", :categories => ["programming-langauge"]},
      
  # C++
  { :name => "C++", :url => "http://en.wikipedia.org/wiki/C%2B%2B", :description => "C++ is a statically typed, free-form, multi-paradigm, compiled, general-purpose programming language.", :categories => ["programming-langauge"] },
  
  # C#
  { :name => "C#", :url => "http://en.wikipedia.org/wiki/C_Sharp_(programming_language)", :description => "C# is a multi-paradigm programming language encompassing imperative, declarative, functional, generic, object-oriented (class-based), and component-oriented programming disciplines.", :categories => ["programming-langauge"] },
  
  # ColdFusion
  { :name => "ColdFusion", :url => "http://www.adobe.com/products/coldfusion/", :description => "Adobe ColdFusion application server and software enables developers to rapidly build, deploy, and maintain robust Internet applications for the enterprise.", :categories => ["programming-langauge"], :keyword => "coldfusion" },

  # Erlang
  { :name => "Erlang", :url => "http://www.erlang.org/", :description => "Erlang is a general-purpose concurrent, garbage-collected programming language and runtime system.", :categories => ["programming-langauge"], :keyword => "erlang" },
  
  # Go
  { :name => "Go", :url => "http://golang.org/", :description => "The Go programming language is an open source project to make programmers more productive.", :categories => ["programming-langauge"], :keyword => "go programming language" },

  # Groovy
  { :name => "Groovy", :url => "http://groovy.codehaus.org/", :description => "An agile dynamic language for the Java Platform", :categories => ["programming-langauge"], :keyword => "groovy" },
  
  # Haskell
  { :name => "Haskell", :url => "http://www.haskell.org/", :description => "Haskell is an advanced purely-functional programming language.", :categories => ["programming-langauge"], :keyword => "haskell" },
  
  # Java
  { :name => "Java", :url => "http://www.java.com/", :description => "The Java Programming Language is a general-purpose, concurrent, strongly typed, class-based object-oriented language. It is normally compiled to the bytecode instruction set and binary format defined in the Java Virtual Machine Specification.", :categories => ["programming-langauge"], :keyword => "haskell" },  
    
  # Javascript
  { :name => "Javascript", :url => "http://en.wikipedia.org/wiki/JavaScript", :description => "JavaScript is an implementation of the ECMAScript language standard and is typically used to enable programmatic access to computational objects within a host environment.", :categories => ["programming-langauge"], :keyword => "javascript" },
  { :name => "jQuery", :url => "http://jquery.com/", :description => "jQuery is a fast and concise JavaScript Library that simplifies HTML document traversing, event handling, animating, and Ajax interactions for rapid web development. jQuery is designed to change the way that you write JavaScript.", :parent => "javascript", :categories => ["framework"], :keyword => "jquery" },
  { :name => "node.js", :url => "http://nodejs.org/", :description => "Evented I/O for V8 JavaScript.", :parent => "javascript", :categories => ["framework"], :keyword => "node.js" },
  { :name => "jQuery UI", :url => "http://jqueryui.com/", :description => "jQuery UI provides abstractions for low-level interaction and animation, advanced effects and high-level, themeable widgets, built on top of the jQuery JavaScript Library, that you can use to build highly interactive web applications.", :parent => "javascript", :categories => ["framework"], :keyword => "jquery ui" },
  { :name => "Prototype", :url => "http://www.prototypejs.org/", :description => "Prototype is a JavaScript Framework that aims to ease development of dynamic web applications.", :parent => "javascript", :categories => ["framework"], :keyword => "prototype" },
  { :name => "Scriptaculous", :parent => "javascript", :categories => ["framework"], :description => "Scriptaculous provides you with easy-to-use, cross-browser user interface JavaScript libraries to make your web sites and web applications fly.", :url => "http://script.aculo.us/", :keyword => "scriptaculous" },
  { :name => "MooTools", :url => "http://mootools.net/", :parent => "javascript", :categories => ["framework"], :description => "MooTools is a compact, modular, Object-Oriented JavaScript framework designed for the intermediate to advanced JavaScript developer.", :keyword => "mootools" },
  { :name => "YUI", :url => "http://developer.yahoo.com/yui/", :parent => "javascript", :description => "The YUI Library is a set of utilities and controls, written with JavaScript and CSS, for building richly interactive web applications using techniques such as DOM scripting, DHTML and AJAX.", :keyword => "yui" },

  # Lua
  { :name => "Lua", :url => "http://www.lua.org/", :description => "Lua is a powerful, fast, lightweight, embeddable scripting language.", :categories => ["framework"], :keyword => "lua" },

  # Lisp
  { :name => "Lisp", :url => "http://en.wikipedia.org/wiki/Lisp_(programming_language)", :description => "Lisp is a family of computer programming languages with a long history and a distinctive, fully parenthesized syntax.", :categories => ["framework"], :keyword => "lisp" },

  # Objective-C
  { :name => "Objective-C", :url => "http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjectiveC/Introduction/introObjectiveC.html", :description => "The Objective-C language is a simple computer language designed to enable sophisticated object-oriented programming.", :categories => ["programming-langauge"], :keyword => "objective c" },
  
  # Perl
  { :name => "Perl", :url => "http://www.perl.org/", :description => "Perl is a highly capable, feature-rich programming language with over 23 years of development.", :categories => ["programming-langauge"], :keyword => "perl" },

  # PHP
  { :name => "PHP", :url => "http://php.net/", :description => "PHP is a widely-used general-purpose scripting language that is especially suited for Web development and can be embedded into HTML.", :parent => "C", :categories => ["programming-langauge"], :keyword => "php" },
  { :name => "WordPress", :url => "http://wordpress.org", :description => "WordPress is web software you can use to create a beautiful website or blog. We like to say that WordPress is both free and priceless at the same time.", :parent => "PHP", :categories => ["cms"], :keyword => "wordpress" },

  # Python
  { :name => "Python", :url => "http://www.python.org/", :description => "Python is a programming language that lets you work more quickly and integrate your systems more effectively.", :categories => ["programming-langauge"], :keyword => "python" },
  { :name => "Tornado", :url => "http://www.tornadoweb.org/", :description => "Tornado is an open source version of the scalable, non-blocking web server and tools that power FriendFeed.", :parent => "Python", :categories => ["framework"], :keyword => "tornado" },
  { :name => "Pylons", :url => "http://pylonshq.com/", :description => "Pylons is a lightweight web framework emphasizing flexibility and rapid development.", :parent => "Python", :categories => ["framework"], :keyword => "pylons" },
  { :name => "Twisted", :url => "http://twistedmatrix.com/trac/", :description => "Twisted is an event-driven networking engine written in Python.", :parent => "Python", :categories => ["framework"], :keyword => "twisted" },
  
  # Ruby
  { :name => "Ruby", :url => "http://ruby-lang.org/", :description => "A dynamic, interpreted, open source programming language with a focus on simplicity and productivity.", :categories => ["programming-langauge"], :keyword => "ruby" },
    # Frameworks
    { :name => "Ruby on Rails", :url => "http://rubyonrails.org/", :description => "Ruby on Rails is an open source web application framework for the Ruby programming language. It is intended to be used with an Agile development methodology that is used by web developers for rapid development.", :parent => "Ruby", :categories => ["framework"], :keyword => "ruby on rails" },
    { :name => "Sinatra", :url => "http://www.sinatrarb.com/", :parent => "Ruby", :categories => ["framework"], :description => "Sinatra is a DSL for quickly creating web applications in Ruby with minimal effort.", :keyword => "sinatra" },
    # Popular gems
    { :name => "Jekyll", :url => "https://github.com/mojombo/jekyll", :parent => "Ruby", :categories => ["library"], :description => "Jekyll is a blog-aware, static site generator in Ruby", :keyword => "jekyll" },
    { :name => "Paperclip", :url => "https://github.com/thoughtbot/paperclip", :description => "Easy file attachment management for ActiveRecord.", :parent => "Ruby", :categories => ["library"], :keyword => "paperclip" },
    { :name => "Formtastic", :url => "https://github.com/justinfrench/formtastic", :description => "A Rails form builder plugin with semantically rich and accessible markup.", :parent => "Ruby", :categories => ["library"], :keyword => "formtastic" },
    { :name => "WillPaginate", :url => "https://github.com/mislav/will_paginate", :description => "Adaptive pagination plugin for web frameworks and other applications.", :parent => "Ruby", :categories => ["library"], :keyword => "willpaginate" },
    { :name => "Authlogic", :url => "https://github.com/binarylogic/authlogic", :description => "A simple model based ruby authentication solution.", :parent => "Ruby", :categories => ["library"], :keyword => "authlogic" },
    # Auth
    { :name => "Devise", :url => "https://github.com/plataformatec/devise", :description => "Flexible authentication solution for Rails with Warden.", :parent => "Ruby", :categories => ["library"], :keyword => "devie" },
    { :name => "Restful Authentication", :url => "https://github.com/technoweenie/restful-authentication", :description => "Generates common user authentication code for Rails/Merb, with a full test/unit and rspec suite and optional Acts as State Machine support built-in.", :parent => "Ruby", :categories => ["library"], :keyword => "restful authentication" },
    { :name => "Clearance", :url => "https://github.com/thoughtbot/clearance", :description => "Rails authentication with email & password.", :parent => "Ruby", :categories => ["library"] },
    # Testing
    { :name => "Cucumber", :url => "https://github.com/aslakhellesoy/cucumber", :description => "BDD that talks to domain experts first and code second.", :parent => "Ruby", :categories => ["library", "testing"], :keyword => "cucumber" },
    { :name => "Rspec", :url => "https://github.com/dchelimsky/rspec", :description => "Behaviour Driven Development framework for Ruby.", :parent => "Ruby", :categories => ["library", "testing"], :keyword => "rspec" },
    { :name => "Shoulda", :url => "https://github.com/thoughtbot/shoulda", :description => "Makes tests easy on the fingers and the eyes.", :parent => "Ruby", :categories => ["library", "testing"], :keyword => "shoulda" },
    { :name => "Steak", :url => "https://github.com/cavalle/steak", :description => "Minimalist acceptance testing on top of RSpec", :parent => "Ruby", :categories => ["library", "testing"], :keyword => "steak" },
  
  
  # Scala
  { :name => "Scala", :url => "http://www.scala-lang.org/", :description => "Scala is a modern multi-paradigm programming language designed to express common programming patterns in a concise, elegant, and type-safe way.", :parent => "Java", :categories => ["programming-langauge"], :keyword => "scala" },

  # Smalltalk
  { :name => "Smalltalk", :url => "http://en.wikipedia.org/wiki/Smalltalk", :description => "Smalltalk is an object-oriented, dynamically typed, reflective programming language.", :categories => ["programming-langauge"], :keyword => "smalltalk" },

  # Visual Basic
  { :name => "Visual Basic", :url => "http://en.wikipedia.org/wiki/Visual_Basic", :description => "Visual Basic (VB) is the third-generation event-driven programming language and integrated development environment (IDE) from Microsoft for its COM programming model.", :categories => ["programming-langauge"], :keyword => "visual basic" },
  
  
  # Databases
  { :name => "MySQL", :url => "http://mysql.org", :description => "The world's most popular open source database.", :categories => ["datastore"], :keyword => "mysql" },
  { :name => "PostgreSQL", :url => "http://www.postgresql.org/", :description => "The world's most advanced open source database.", :categories => ["datastore"], :keyword => "postgres" },
  { :name => "MongoDB", :url => "http://www.mongodb.org/", :description => "MongoDB is a scalable, high-performance, open source, document-oriented database.", :categories => ["datastore"], :keyword => "mongo" },
  { :name => "Memcached", :url => "http://memcached.org/", :description => "Free & open source, high-performance, distributed memory object caching system, generic in nature, but intended for use in speeding up dynamic web applications by alleviating database load.", :categories => ["datastore"], :keyword => "memcached" },
  { :name => "Cassandra", :url => "http://cassandra.apache.org/", :description => "Cassandra is a highly scalable, eventually consistent, distributed, structured key-value store.", :categories => ["datastore"], :keyword => "cassandra" },
  { :name => "Redis", :url => "http://redis.io/", :description => "Redis is an open source, advanced key-value store.", :categories => ["datastore"], :keyword => "redis" },
  { :name => "Microsoft SQL Server", :url => "http://www.microsoft.com/sqlserver/", :description => "Microsoft SQL Server is a relational model database server produced by Microsoft.", :categories => ["datastore"], :keyword => "mssql" },
  { :name => "Tokyo Cabinet", :url => "http://fallabs.com/tokyocabinet/", :description => "Tokyo Cabinet is a library of routines for managing a database.", :categories => ["datastore"], :keyword => "tokyo cabinet" },
  { :name => "Kyoto Cabinet", :url => "http://fallabs.com/kyotocabinet/", :description => "Kyoto Cabinet is a library of routines for managing a database.", :categories => ["datastore"], :keyword => "kyoto cabinet" },
  { :name => "Voldemort", :url => "http://project-voldemort.com/", :description => "Voldemort is a distributed key-value storage system.", :categories => ["datastore"], :keyword => "voldemort" },
  { :name => "CouchDB", :url => "http://couchdb.apache.org/", :description => "Apache CouchDB is a document-oriented database that can be queried and indexed in a MapReduce fashion using JavaScript.", :categories => ["datastore"], :keyword => "couchdb" },
  { :name => "Riak", :url => "http://wiki.basho.com/", :description => "Riak is a Dynamo-inspired database.", :categories => ["datastore"], :keyword => "riak" },
  { :name => "SQLite", :url => "http://www.sqlite.org/", :description => "SQLite is a software library that implements a self-contained, serverless, zero-configuration, transactional SQL database engine.", :categories => ["datastore"], :keyword => "sqlite" },
  
  # Services
  { :name => "Twitter API", :url => "http://dev.twitter.com/", :description => "Create cool applications that integrate with Twitter.", :categories => ["api", "website"], :keyword => "twitter" },
  { :name => "Netflix API", :url => "http://developer.netflix.com/", :description => "The Netflix API allows anyone to build their own Netflix-integrated applications for the web, the desktop, mobile devices or the TV.", :categories => ["api", "website"], :keyword => "netflix" },
  { :name => "Flickr API", :url => "http://www.flickr.com/services/api/", :description => "The Flickr API consists of a set of callable methods, and some API endpoints.", :categories => ["api", "website"], :keyword => "flickr" },
  { :name => "Delicious API", :url => "http://www.delicious.com/help/api/", :description => "Read/write access to your Delicious bookmarks and tags via an HTTP-based interface.", :categories => ["api", "website"], :keyword => "delicious" },
  { :name => "Digg API", :url => "http://developers.digg.com/", :description => "Harness Digg's API to bring the news to your users in awesome new ways.", :categories => ["api", "website"], :keyword => "digg" },
  { :name => "Facebook API", :url => "http://developers.facebook.com/", :description => "Facebook's powerful APIs enable you to create social experiences to drive growth and engagement on your web site.", :categories => ["api", "website"], :keyword => "facebook" },
  { :name => "Google Maps API", :url => "http://code.google.com/apis/maps/index.html", :description => "Google Maps has a wide array of APIs that let you embed the robust functionality and everyday usefulness of Google Maps into your own website and applications, and overlay your own data on top of them.", :categories => ["api", "website"], :keyword => "google maps" },
  { :name => "Google Earth API", :url => "http://code.google.com/apis/earth/", :description => "The Google Earth Plug-in and its JavaScript API let you embed Google Earth, a true 3D digital globe, into your web pages.", :categories => ["api", "website"], :keyword => "google earth" },
  { :name => "Google AdSense API", :url=> "http://code.google.com/apis/adsense/", :description => "The Google AdSense API is ideal for developers whose users create their own content through blogging, web publishing, forum/wiki/community creation, or any other application where substantial web content is generated.", :categories => ["api", "website"], :keyword => "adsense" },
  { :name => "Google Feed API", :url => "http://code.google.com/apis/feed/", :description => "With the Feed API, you can download any public Atom, RSS, or Media RSS feed using only JavaScript, so you can easily mash up feeds with your content and other APIs like the Google Maps API.", :categories => ["api", "website"] },
  { :name => "Youtube API", :url => "http://www.youtube.com/dev", :description => "YouTube offers access to the YouTube video repository and community features via a GoogleData (\"GData\") API.", :categories => ["api", "website"], :keyword => "youtube" },
  { :name => "Google Image Search API", :url => "http://code.google.com/apis/imagesearch/", :description => "The Google Image Search API provides a JavaScript interface to embed Google Image Search results in your website or application.", :categories => ["api", "website"] },
  { :name => "Google News Search API", :url => "http://code.google.com/apis/newssearch/", :description => "The Google News Search API provides a JavaScript interface to embed Google News Search results in your website or application.", :categories => ["api", "website"] },
  { :name => "Yahoo Search API", :url => "http://developer.yahoo.com/search/", :description => "Yahoo! Search offers an array of web services to provide you with access to our investments in search technology and infrastructure.", :categories => ["api", "website"] },
  { :name => "Ebay API", :url => "http://developer.ebay.com/", :description => "Tap into the largest eCommerce Opportunity.", :categories => ["api", "website"], :keyword => "ebay" },
  { :name => "MediaWiki API", :url => "http://www.mediawiki.org/wiki/API", :description => "Provides direct, high-level access to the data contained in the MediaWiki databases.", :categories => ["api", "website"] },
  { :name => "Freebase API", :url => "http://wiki.freebase.com/wiki/API", :description => "All of Freebase's data (all entities and relationships in the graph (including full history), as well as blob data such as descriptions and images) are fully accessible through a REST API (Restful).", :categories => ["api", "website"], :keyword => "freebase" },
  { :name => "Yelp API", :url => "http://www.yelp.com/developers/documentation", :description => "Yelp's API program enables you to access trusted Yelp information in real time, such as business listing info, overall business rating, and recent review excerpts", :categories => ["api", "website"], :keyword => "yelp" },
  { :name => "SimplyHired API", :url => "http://www.simplyhired.com/a/publishers/overview", :description => "Simply Hired's publisher program makes it easy to add relevant job listings to your website.", :categories => ["api", "website"], :keyword => "simplyhired" },
  { :name => "Zillow API", :url => "http://www.zillow.com/howto/api/APIOverview.htm", :description => "The Zillow API Network turns member sites into mini real estate portals by offering fresh and provocative real estate content to keep people coming back.", :categories => ["api", "website"], :keyword => "zillow" },
  { :name => "Instragram API", :url => "http://instagram.com/developer/", :description => "The first version of the Instagram API is an exciting step forward towards making it easier for users to have open access to their data.", :categories => ["api", "website"], :keyword => "instagram" },
  { :name => "Twilio API", :url => "http://www.twilio.com/", :description => "Twilio provides a cloud API for voice and SMS communications that leverages existing web development skills, resources and infrastructure.", :categories => ["api", "website"], :keyword => "twilio" },
  { :name => "Last.fm API", :url => "http://www.last.fm/api", :description => "The Last.fm API allows anyone to build their own programs using Last.fm data, whether they're on the web, the desktop or mobile devices.", :categories => ["api", "website"], :keyword => "last.fm" },
  { :name => "Hoptoad", :url => "http://www.hoptoadapp.com", :description => "Hoptoad collects errors generated by other applications, and aggregates the results for developer review.", :categories => ["service", "api", "website"], :keyword => "hoptoad" },
  { :name => "Gowalla API", :url => "http://gowalla.com/api/docs", :description => "The Gowalla API is another way to access your Gowalla data - one that makes it easy for third-party tools to interact with the service.", :categories => ["api", "website"], :keyword => "gowalla" },
  { :name => "Foursquare API", :url => "http://developer.foursquare.com/", :description => "The foursquare api gives you access to all of the data used by the foursquare mobile applications, and, in some cases, even more.", :categories => ["api", "website"], :keyword => "foursquare" },
  { :name => "New Relic", :url => "http://newrelic.com/", :description => "New Relic RPM is the only tool you need to pinpoint and solve performance issues in your Ruby, Java, .NET and PHP apps.", :categories => ["service", "api", "website"], :keyword => "new relic"},
]

tools.each do |attributes|
  link = Link.find_or_create_by_url(attributes[:url], true)
  Tool.find_or_initialize_by_name(attributes[:name]).tap do |tool|
    tool.name = attributes[:name]
    tool.url = attributes[:url]
    tool.description = attributes[:description]
    tool.keyword = attributes[:keyword]
    tool.language = Tool.find_by_name(attributes[:parent]) if attributes[:parent]
    tool.categories = Category.where(["cached_slug IN (?)", attributes[:categories]])
    tool.save!
  end
end
puts "Tools complete..."






sites = [
  { :title => "Google", :url => "http://google.com/", :alexa_us_rank => 1, :alexa_global_rank => 1, :google_pagerank => 10, :tools => ["javascript"], :description => "Enables users to search the Web, Usenet, and images. Features include PageRank, caching and translation of results, and an option to find similar pages." },
  { :title => "Facebook", :url => "http://facebook.com/", :alexa_us_rank => 2, :alexa_global_rank => 2, :google_pagerank => 10, :tools => ["javascript", "cassandra"], :description => "A social utility that connects people, to keep up with friends, upload photos, share links and videos." },
  { :title => "YouTube", :url => "http://youtube.com/", :alexa_us_rank => 3, :alexa_global_rank => 3, :google_pagerank => 9, :description => "YouTube is a way to get your videos to the people who matter to you." },
  { :title => "Disqus", :url => "http://disqus.com/", :alexa_us_rank => 1709, :alexa_global_rank => 1766, :google_pagerank => 8, :tools => ["javascript", "mongodb", "python", "postgresql"], :description => "Disqus is a comments platform that helps you build an active community from your website's audience." },
  { :title => "Twitter", :url => "http://twitter.com/", :alexa_us_rank => 9, :alexa_global_rank => 9, :google_pagerank => 9, :description => "Twitter is without a doubt the best way to share and discover what is happening right now.", :tools => ["ruby", "ruby on rails", "jquery", "javascript"] },
  { :title => "Foursquare", :url => "http://foursquare.com/", :alexa_us_rank => 874, :alexa_global_rank => 875, :google_pagerank => 7, :description => "Foursquare gives you and your friends new ways to explore your city.", :tools => ["ruby", "ruby on rails", "javascript"] },
  { :title => "LiveJournal", :url => "http://livejournal.com/", :alexa_us_rank => 86, :alexa_global_rank => 73, :google_pagerank => 8, :description => "A global community of friends who share your unique passions and interests.", :tools => ["memcached", "perl", "javascript"] },
  { :title => "The New Yorks Times", :url => "http://www.nytimes.com/", :alexa_us_rank => 79, :alexa_global_rank => 88, :google_pagerank => 9, :description => "Find breaking news, multimedia, reviews & opinion on Washington, business, sports, movies, travel, books, jobs, education, real estate, cars & more.", :tools => ["mongodb"] },
  { :title => "SourceForge", :url => "http://sourceforge.com/", :alexa_us_rank => 117, :alexa_global_rank => 133, :google_pagerank => 8, :description => "Find, create, and publish Open Source software for free.", :tools => ["mongodb"] },
  { :title => "Digg", :url => "http://digg.com/", :alexa_us_rank => 129, :alexa_global_rank => 135, :google_pagerank => 8, :description => "The best news, videos and pictures on the web as voted on by the Digg community. Breaking news on Technology, Politics, Entertainment, and more!", :tools => ["cassandra"] },
  { :title => "Reddit", :url => "http://www.reddit.com/", :alexa_us_rank => 166, :alexa_global_rank => 144, :google_pagerank => 8, :description => "The voice of the internet -- news before it happens.", :tools => ["cassandra", "jquery", "javascript"] },
  { :title => "Bitly", :url => "http://bit.ly/", :alexa_us_rank => 119, :alexa_global_rank => 164, :google_pagerank => 7, :description => "Shorten, share and track your links.", :tools => ["cassandra"] },
  { :title => "Github", :url => "https://github.com/", :alexa_us_rank => 967, :alexa_global_rank => 1017, :google_pagerank => 6, :description => "GitHub is the best way to collaborate with others. Fork, send pull requests and manage all your public and private git repositories.", :tools => ["cassandra"] },
  { :title => "Hacker News", :url => "http://news.ycombinator.com/", :alexa_us_rank => 1919, :alexa_global_rank => 1899, :google_pagerank => 7, :description => "Read the latest tech news for hackers.", :tools => ["jquery", "javascript"] },
  { :title => "37signals", :url => "http://37signals.com/", :alexa_us_rank => 2506, :alexa_global_rank => 3165, :google_pagerank => 7, :description => "Goodbye to bloat. Simple, focused software that does just what you need and nothing you don't.", :tools => ["ruby on rails", "ruby"] },
  { :title => "Heroku", :url => "http://heroku.com/", :alexa_us_rank => 6461, :alexa_global_rank => 6024, :google_pagerank => 6, :description => "Ruby Cloud Platform as a Service. Fast, frictionless, and maintenance free Ruby hosting.", :tools => ["ruby"] },
  { :title => "SponsoredTweets", :url => "http://sponsoredtweets.com", :alexa_us_rank => 5646, :alexa_global_rank => 5881, :google_pagerank => 5, :description => "Sponsored Tweets is a Twitter advertising platform that connects advertisers with tweeters. The site provides robust targeting and detailed analytics.", :tools => ["ruby", "ruby on rails", "jquery", "mysql", "twitter api", "shoulda", "willpaginate", "formtastic", "jquery ui"] },
  { :title => "Convore", :url => "https://convore.com/", :alexa_us_rank => 96214, :alexa_global_rank => 79865, :google_pagerank => 0, :description => "Convore is a quick way to instant message with groups of friends in real-time. Join public or private groups and talk about anything", :tools => ["python"] },
  { :title => "Harvest", :url => "http://getharvest.com/", :alexa_us_rank => 34714, :alexa_global_rank => 37188, :google_pagerank => 6, :description => "Simple time tracking, fast online invoicing, and powerful reporting software. Simplify employee timesheets and billing. Get started for free.", :tools => ["ruby", "ruby on rails"] }
]
sites.each do |attributes|
  link = Link.find_or_create_by_url(attributes[:url], true)
  Site.find_or_initialize_by_title(attributes[:title]).tap do |site|
    site.url = attributes[:url]
    site.description = attributes[:description]
    site.skip_ranks = true
    site.alexa_us_rank = attributes[:alexa_us_rank]
    site.alexa_global_rank = attributes[:alexa_global_rank]
    site.google_pagerank = attributes[:google_pagerank]
    site.save!
    
    # Add all usings
    site.tools = Tool.where(["name IN (?)", attributes[:tools]])
    site.save
  end
end
puts "Sites complete..."



csv = <<-DONE
"http://en.wikipedia.org/favicon.ico","org.wikipedia","favicon.ico","image/x-icon",318,"2011-03-16 03:23:40"
"http://www.adobe.com/favicon.ico","com.adobe","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:41"
"http://golang.org/favicon.ico","org.golang","favicon.ico","image/x-icon",785,"2011-03-16 03:23:41"
"http://www.erlang.org/favicon.ico","org.erlang","favicon.ico","image/x-icon",318,"2011-03-16 03:23:42"
"http://www.java.com/favicon.ico","com.java","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:42"
"http://static.jquery.com/favicon.ico","com.jquery","favicon.ico","text/plain",3638,"2011-03-16 03:23:42"
"http://www.haskell.org/favicon.ico","org.haskell","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:42"
"http://www.prototypejs.org/images/fav.png","org.prototypejs","fav.png","image/png",533,"2011-03-16 03:23:42"
"http://jqueryui.com/images/favicon.ico","com.jqueryui","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:43"
"http://script.aculo.us/favicon.ico","us.aculo","favicon.ico","image/x-icon",894,"2011-03-16 03:23:43"
"http://www.lua.org/favicon.ico","org.lua","favicon.ico","image/x-icon",1078,"2011-03-16 03:23:43"
"http://mootools.net/assets/icons/icon.png","net.mootools","icon.png","image/png",386,"2011-03-16 03:23:43"
"http://developer.apple.com/favicon.ico","com.apple","favicon.ico","image/vnd.microsoft.icon",4150,"2011-03-16 03:23:44"
"http://l.yimg.com/a/i/ydn/favicon2.ico","com.yahoo","favicon2.ico","image/x-icon",318,"2011-03-16 03:23:44"
"http://www.perl.org/favicon.ico","org.perl","favicon.ico","image/x-icon",318,"2011-03-16 03:23:44"
"http://s.wordpress.org/favicon.ico?3","org.wordpress","favicon.ico","application/octet-stream",1150,"2011-03-16 03:23:44"
"http://www.python.org/favicon.ico","org.python","favicon.ico","image/x-icon",15086,"2011-03-16 03:23:45"
"http://twistedmatrix.com/images/favicon.png","com.twistedmatrix","favicon.png","image/png",477,"2011-03-16 03:23:45"
"http://www.sinatrarb.com/images/favicon.ico","com.sinatrarb","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:45"
"http://www.ruby-lang.org/favicon.ico","org.ruby-lang","favicon.ico","image/x-icon",6766,"2011-03-16 03:23:46"
"https://github.com/fluidicon.png","com.github","fluidicon.png","image/png",48532,"2011-03-16 03:23:46"
"http://www.mongodb.org/favicon.ico","org.mongodb","favicon.ico","application/octet-stream",1150,"2011-03-16 03:23:46"
"http://www.scala-lang.org/sites/default/files/favicon.gif","org.scala-lang","favicon.gif","image/gif",570,"2011-03-16 03:23:46"
"http://www.postgresql.org/favicon.ico","org.postgresql","favicon.ico","image/x-icon",2550,"2011-03-16 03:23:46"
"http://cassandra.apache.org/favicon.ico","org.apache","favicon.ico","image/x-icon",3638,"2011-03-16 03:23:47"
"http://redis.io/images/favicon.png","io.redis","favicon.png","image/png",6740,"2011-03-16 03:23:47"
"http://project-voldemort.com/images/vold-logo-small.png","com.project-voldemort","vold-logo-small.png","image/png",4705,"2011-03-16 03:23:47"
"http://couchdb.apache.org/./favicon.ico","org.apache","favicon.ico","image/x-icon",3638,"2011-03-16 03:23:48"
"http://www.microsoft.com/favicon.ico","com.microsoft","favicon.ico","image/x-icon",3638,"2011-03-16 03:23:48"
"http://www.sqlite.org/favicon.ico","org.sqlite","favicon.ico","application/octet-stream",318,"2011-03-16 03:23:48"
"http://www.basho.com/favicon.ico","com.basho","favicon.ico","text/plain",1150,"2011-03-16 03:23:49"
"http://dev.twitter.com/images/dev/favicon.ico","com.twitter","favicon.ico","image/x-icon",1406,"2011-03-16 03:23:49"
"http://developers.digg.com/files/favicon.ico","com.digg","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:49"
"http://developers.facebook.com/favicon.ico","com.facebook.developers","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:50"
"http://code.google.com/favicon.ico","com.google","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:49"
"http://www.delicious.com/favicon.ico","com.delicious","favicon.ico","image/x-icon",2038,"2011-03-16 03:23:50"
"http://l.yimg.com/g/favicon.ico","com.flickr","favicon.ico","image/vnd.microsoft.icon",92854,"2011-03-16 03:23:51"
"http://s.ytimg.com/yt/favicon-vflZlzSbU.ico","com.youtube","favicon-vflZlzSbU.ico","image/x-icon",1150,"2011-03-16 03:23:51"
"http://www.mediawiki.org/favicon.ico","org.mediawiki","favicon.ico","image/x-icon",1406,"2011-03-16 03:23:51"
"http://www.yelp.com/favicon.ico","com.yelp","favicon.ico","image/x-icon",3382,"2011-03-16 03:23:52"
"http://developer.ebay.com/favicon.ico","com.ebay","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:52"
"http://www.simplyhired.com/favicon.ico","com.simplyhired","favicon.ico","image/x-icon",1406,"2011-03-16 03:23:52"
"http://instagram.com/static/images/favicon.ico","com.instagram","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:53"
"http://static0.twilio.com/resources/images/favicon.ico","com.twilio","favicon.ico","text/plain",3638,"2011-03-16 03:23:53"
"http://gowalla.com/favicon.ico","com.gowalla","favicon.ico","image/x-icon",472,"2011-03-16 03:23:53"
"http://foursquare.com/favicon.ico","com.foursquare","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:53"
"http://www.hoptoadapp.com/images/hoptoad-fluid.png","com.hoptoadapp","hoptoad-fluid.png","image/png",34053,"2011-03-16 03:23:53"
"http://cdn.last.fm/flatness/favicon.2.ico","fm.last","favicon.2.ico","image/x-icon",1150,"2011-03-16 03:23:53"
"http://newrelic.com/favicon.ico","com.newrelic","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:54"
"http://www.google.com/favicon.ico","com.google","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:54"
"http://mediacdn.disqus.com/1300226790/img/favicon.ico","com.disqus","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:54"
"http://www.facebook.com/favicon.ico","com.facebook","favicon.ico","image/x-icon",152,"2011-03-16 03:23:54"
"http://a1.twimg.com/a/1300224005/images/favicon.ico","com.twitter","favicon.ico","image/vnd.microsoft.icon",1150,"2011-03-16 03:23:54"
"http://a.fsdn.com/con/img/sftheme/favicon.ico","net.sourceforge","favicon.ico","image/x-icon",1406,"2011-03-16 03:23:54"
"http://bit.ly/s/v297/graphics/favicon.png","ly.bit","favicon.png","image/png",846,"2011-03-16 03:23:56"
"http://cdn1.diggstatic.com/img/favicon.a015f25c.ico","com.digg","favicon.a015f25c.ico","image/x-icon",1150,"2011-03-16 03:23:55"
"http://nav.heroku.com/images/logos/fluid.png","com.heroku","fluid.png","image/png",59382,"2011-03-16 03:23:56"
"http://37signals.com/favicon.ico","com.37signals","favicon.ico","image/x-icon",2862,"2011-03-16 03:23:55"
"http://sponsoredtweets.com/wp-content/themes/sponsoredtweets/img/favicon.ico","com.sponsoredtweets","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:55"
"https://convore.com/media/images/touch-icon.png","com.convore","touch-icon.png","image/png",289,"2011-03-16 03:23:56"
"http://css.nyt.com/images/icons/nyt.ico","com.nytimes","nyt.ico","image/x-icon",15086,"2011-03-16 03:23:56"
"http://www.getharvest.com/favicon.ico","com.getharvest","favicon.ico","image/x-icon",1150,"2011-03-16 03:23:56"
"http://ycombinator.com/favicon.ico","com.ycombinator","favicon.ico","image/x-icon",894,"2011-03-16 03:23:57"
DONE

CSV.parse(csv) do |row|
  Favicon.create({ :url => row[0], 
                   :uid => row[1], 
                   :favicon_file_name => row[2],
                   :favicon_content_type => row[3], 
                   :favicon_file_size => row[4], 
                   :favicon_updated_at => row[5] })
end
puts "Favicons complete..."
