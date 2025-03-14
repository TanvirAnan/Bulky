﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BulkyBook.DataAccess.Repository.IRepository
{
    public interface IUnitofWork
    {
        ICatagoryRepository Catagory { get; set; }
        IProductRepository Product { get; set; }
        void Save();
    }
}
