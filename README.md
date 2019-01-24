# MyLibrary

This app allows users to create their own book library by adding books from an online search.


## Project Overview

This project was developed to satisfy the fifth and final requirement for graduating from [Udacity's iOS Developer Nanodegree program].

# Table of Contents
* [App Description](#description)<br />
* [Project Details](#projectdetails)<br />
* [App Requirements](#appreq)<br />
* [Feature Wishlist](#features)

<a name="description">

## App Description

The user can search for a book title, an author ,an ISBN or publisher on online search. Once the search results are displayed in a table view, the user can select a book to open a detail view of this book. In the detail view the book can be saved adding it to the book list. 

Furthermore a preview of the book can be opened in Safari by clicking on the "Preview on Google Books" button in the detail view of the book.

All added books are displayed in the book list view. The books can be sorted by title or author. Selecting an added book will open a detail view of this book as well. Additionally the book can be shared (e.g. via iMessage) by clicking the "Share" button. 

A book can be deleted from the own book list by swiping left on the respective book cell.

<a name="projectdetails">

## Project Details

### User Interface

* Three main View Controllers:
  - View Controller
  - Search View Controller
  - Detail View Controller
* All three main View Controllers are using a Table View
* Book Search is presented modally.
* Activity View Controller is displayed to share a book
* Books can be sorted by title/author/isbn/publisher via Segmented Control

### Networking

* Google Books is used to retrieve book information like:
  - Book cover image
  - Title 
  - Author
  - Publisher 
  - Publication Date
  - Pages
  - Categories
  - ISBN
  - Google Books Preview Link
* While an online search is in progress, an Activity Indicator is displayed
* An alert view will be displayed, if there was a network error

### Persistence

* Books added to the Book List are stored in Core Data

<a name="ui">

## App Requirements

* Xcode 10.1
* iOS 12.1 SDK
* a Mac that runs (OS X 10.14.2)



