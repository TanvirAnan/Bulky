using BulkyBook.DataAccess.Repository.IRepository;
using BulkyBook.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BulkyBook.DataAccess.Data;

namespace BulkyBook.DataAccess.Repository
{
    public class CatagoryRepository : Repository<Catagory>, ICatagoryRepository
    { 

        private ApplicationDbContext _db;
        public CatagoryRepository(ApplicationDbContext db):base(db) 
        {
            _db = db;
        }


        public void Save()
        {
            _db.SaveChanges();
        }

        public void Update(Catagory obj)
        {
            _db.Catagories.Update(obj);
        }
    }
}
