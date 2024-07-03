using Bulky.DataAccess.Repository.IRepository;
using Bulky.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bulky.DataAccess.Data;

namespace Bulky.DataAccess.Repository
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
