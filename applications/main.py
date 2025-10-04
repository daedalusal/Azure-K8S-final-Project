from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Bookstore API", version="0.1.0")

# In-memory storage (replace with database in production)
books_db = [
    {
        "id": 1,
        "name": "The Great Gatsby",
        "author": "F. Scott Fitzgerald",
        "isbn": "978-0-7432-7356-5",
        "price": 12.99
    },
    {
        "id": 2,
        "name": "To Kill a Mockingbird",
        "author": "Harper Lee",
        "isbn": "978-0-06-112008-4",
        "price": 14.50
    },
    {
        "id": 3,
        "name": "1984",
        "author": "George Orwell",
        "isbn": "978-0-452-28423-4",
        "price": 13.25
    }
]

class Book(BaseModel):
    name: str
    author: str
    isbn: str
    price: float

@app.get("/")
def read_root():
    return {"message": "Python REST API is running!", "status": "healthy", "version": "1.0"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "python-rest-api"}

@app.get("/books")
def list_books():
    return books_db

@app.get("/book/{book_id}")
def get_book(book_id: int):
    for book in books_db:
        if book["id"] == book_id:
            return {"exists": True, "book": book}
    return {"exists": False, "message": f"Book with ID {book_id} not found"}

@app.post("/book/{book_id}")
def add_book(book_id: int, book: Book):
    book_dict = book.dict()
    book_dict["id"] = book_id
    books_db.append(book_dict)
    return {"message": "Book added successfully", "book": book_dict}

@app.put("/book/{book_id}")
def update_book(book_id: int, price: float):
    for book in books_db:
        if book["id"] == book_id:
            book["price"] = price
            return {"message": "Book updated successfully", "book": book}
    return {"message": "Book not found"}

@app.delete("/book/{book_id}")
def delete_book(book_id: int):
    for i, book in enumerate(books_db):
        if book["id"] == book_id:
            deleted_book = books_db.pop(i)
            return {"message": "Book deleted successfully", "book": deleted_book}
    return {"message": "Book not found"}