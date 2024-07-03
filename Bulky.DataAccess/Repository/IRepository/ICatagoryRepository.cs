using BulkyBook.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BulkyBook.DataAccess.Repository.IRepository
{
    public interface ICatagoryRepository:IRepository<Catagory>
    {
        void Update(Catagory obj);
        void Save();
    }
}
