using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BulkyBook.DataAccess.Data;
using BulkyBook.DataAccess.Repository.IRepository;
using BulkyBook.Model;

namespace BulkyBook.DataAccess.Repository
{
    public class UnitofWork : IUnitofWork
    {
        public ICatagoryRepository Catagory {  get; set; }
        public IProductRepository Product { get; set; }


        private ApplicationDbContext _db;
        public UnitofWork(ApplicationDbContext db) 
        {
            _db = db;
            Catagory = new CatagoryRepository(_db);
            Product = new ProductRepository(_db);   
        }

        public void Save()
        {
            _db.SaveChanges();
        }
    }
}
