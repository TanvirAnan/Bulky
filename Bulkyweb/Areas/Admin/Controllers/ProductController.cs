using BulkyBook.DataAccess.Data;
using BulkyBook.DataAccess.Repository;
using BulkyBook.DataAccess.Repository.IRepository;
using BulkyBook.Model;
using BulkyBook.Model.ViewModels;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;


namespace BulkyBookweb.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class ProductController : Controller
    {
        private readonly IUnitofWork _UnitofWork;
        private readonly IWebHostEnvironment _webHostEnvironment;
        public ProductController(IUnitofWork db, IWebHostEnvironment webHostEnvironment)
        {
            _UnitofWork = db;
            _webHostEnvironment = webHostEnvironment;
        }
        public IActionResult Index()
        {
            var obejctProductList = _UnitofWork.Product.GetAll(includeProperties:"Catagory").ToList();
        
            return View(obejctProductList);
        }
        public IActionResult Upsert(int ? id)
        {
            ProductVM productVM = new ProductVM()
            {
                Product = new Product(),
                CatagoryList = _UnitofWork.Catagory.GetAll().Select(u => new SelectListItem
                {
                    Text = u.Name,
                    Value = u.Id.ToString()
                })
            };
            if (id==0 || id==null)
            {
                
                return View(productVM);
            }
            else
            {
                productVM.Product=_UnitofWork.Product.Get(u=>u.Id==id);
                return View(productVM);
            }
            


            
        }
        [HttpPost]
        public IActionResult Upsert(ProductVM obj,IFormFile ? file)
        {
            string wwwRootpath = _webHostEnvironment.WebRootPath;
            if (file != null)
            {
                if (!string.IsNullOrEmpty(obj.Product.ImageUrl))
                {
                    var oldImagePath =
                        Path.Combine(wwwRootpath, obj.Product.ImageUrl.TrimStart('\\'));
                    if (System.IO.File.Exists(oldImagePath))
                    {
                        System.IO.File.Delete(oldImagePath);
                    }
                    
                }
                string filename = Guid.NewGuid().ToString() + Path.GetExtension(file.FileName);
                string productPath = Path.Combine(wwwRootpath, @"images\product");
                using (var fileStream = new FileStream(Path.Combine(productPath, filename), FileMode.Create))
                {
                    file.CopyTo(fileStream);
                }
                obj.Product.ImageUrl = @"\images\product\" + filename;

            }
            if (ModelState.IsValid)
            {
                
                if (obj.Product.Id == 0)
                {
                    if(obj.Product.ImageUrl==null)
                    {
                        obj.Product.ImageUrl = " ";
                    }
                    _UnitofWork.Product.Add(obj.Product);
                }
                else
                {
                    _UnitofWork.Product.Update(obj.Product);
                }

                _UnitofWork.Save();
                //var obejctCatagoryList = _db.Catagories.ToList();
                //return View("Index", obejctCatagoryList);
                TempData["success"] = "Product Successfully Created";
                return RedirectToAction("Index");
            }
            return View();
        }







        #region API CALLS
        [HttpGet]
        public IActionResult GetAll()
        {
            List<Product> objProductList = _UnitofWork.Product.GetAll(includeProperties: "Catagory").ToList();
            return Json(new { data = objProductList });
        }


        [HttpDelete]
        public IActionResult Delete(int? id)
        {
            var productToBeDeleted = _UnitofWork.Product.Get(u => u.Id == id);
            if (productToBeDeleted == null)
            {
                return Json(new { success = false, message = "Error while deleting" });
            }

            var oldImagePath =
                           Path.Combine(_webHostEnvironment.WebRootPath,
                           productToBeDeleted.ImageUrl.TrimStart('\\'));

            if (System.IO.File.Exists(oldImagePath))
            {
                System.IO.File.Delete(oldImagePath);
            }

            _UnitofWork.Product.Remove(productToBeDeleted);
            _UnitofWork.Save();

            return Json(new { success = true, message = "Delete Successful" });
        }

        #endregion












        //public IActionResult Create()
        //{
        //    //Using VIewBag
        //    //        IEnumerable<Microsoft.AspNetCore.Mvc.Rendering.SelectListItem> CatagoryList = _UnitofWork.Catagory
        //    //            .GetAll().Select(u => new SelectListItem
        //    //            {
        //    //                Text = u.Name,
        //    //                Value = u.Id.ToString()
        //    //            });
        //    //ViewBag.CatagoryList = CatagoryList;

        //    //Using VIewModel
        //    ProductVM productVM = new ProductVM()
        //    {
        //        Product = new Product(),
        //        CatagoryList = _UnitofWork.Catagory.GetAll().Select(u => new SelectListItem
        //        {
        //            Text = u.Name,
        //            Value = u.Id.ToString()
        //        })
        //    };


        //    return View(productVM);
        //}
        //[HttpPost]
        //public IActionResult Create(ProductVM obj)
        //{
        //    //if (obj.Name == obj.DisplayOrder.ToString())
        //    //{
        //    //    ModelState.AddModelError("Name", "Name and Display Order Cant be same");
        //    //}

        //    if (ModelState.IsValid)
        //    {
        //        obj.Product.ImageUrl = "a";
        //        _UnitofWork.Product.Add(obj.Product);

        //        _UnitofWork.Save();
        //        //var obejctCatagoryList = _db.Catagories.ToList();
        //        //return View("Index", obejctCatagoryList);
        //        TempData["success"] = "Product Successfully Created";
        //        return RedirectToAction("Index");
        //    }
        //    return View();
        //}
        //public IActionResult Edit(int? id)
        //{
        //    Console.WriteLine(ModelState.IsValid);

        //    //Product obj=_db.Catagories.Find(Id);
        //    //Product obj=_db.Catagories.FirstOrDefault(x => x.Id == Id);
        //    if (id == 0 || id == null)
        //    {
        //        return NotFound();
        //    }
        //    Product? obj = _UnitofWork.Product.Get(x => x.Id == id);
        //    if (obj == null)
        //    {
        //        return NotFound();
        //    }
        //    Console.WriteLine(obj.CatagoryId);
        //    Console.WriteLine(obj.CatagoryId);
        //    return View(obj);
        //}
        //[HttpPost]
        //public IActionResult Edit(Product obj)
        //{

        //    Console.WriteLine(obj.CatagoryId);
        //    Console.WriteLine(ModelState.IsValid);
        //    if (ModelState.IsValid)
        //    {
        //        obj.ImageUrl = "aa";
        //        _UnitofWork.Product.Update(obj);

        //        _UnitofWork.Save();
        //        //var obejctCatagoryList = _db.Catagories.ToList();
        //        //return View("Index", obejctCatagoryList);
        //        TempData["success"] = "Product Successfully Updated";
        //        return RedirectToAction("Index");
        //    }
        //    else
        //    {
        //        foreach (var key in ModelState.Keys)
        //        {
        //            var state = ModelState[key];
        //            foreach (var error in state.Errors)
        //            {
        //                // Log or inspect the errors
        //                Console.WriteLine($"Error in {key}: {error.ErrorMessage}");
        //            }
        //        }
        //        Console.WriteLine("aaa");
        //    }
        //    return View();
        //}


        //public IActionResult Delete(int? id)
        //{
        //    //Product obj=_db.Catagories.Find(Id);
        //    //Product obj=_db.Catagories.FirstOrDefault(x => x.Id == Id);
        //    if (id == 0 || id == null)
        //    {
        //        return NotFound();
        //    }
        //    Product? obj = _UnitofWork.Product.Get(x => x.Id == id);
        //    if (obj == null)
        //    {
        //        return NotFound();
        //    }
        //    return View(obj);
        //}
        //[HttpPost, ActionName("Delete")]
        //public IActionResult DeleteCatagory(int? id)
        //{
        //    if (id == 0 || id == null)
        //    {
        //        return NotFound();
        //    }
        //    Product? obj = _UnitofWork.Product.Get(x => x.Id == id);
        //    if (obj == null)
        //    {
        //        return NotFound();
        //    }

        //    TempData["success"] = "Product Successfully Deleted";
        //    _UnitofWork.Product.Remove(obj);
        //    _UnitofWork.Save();

        //    return RedirectToAction("Index");
        //}
       













}
}
