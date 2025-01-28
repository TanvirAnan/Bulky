using BulkyBook.DataAccess.Data;
using BulkyBook.DataAccess.Repository;
using BulkyBook.DataAccess.Repository.IRepository;
using BulkyBook.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BulkyBookweb.Areas.Admin.Controllers
{
    [Area("Admin")]
    public class CatagoryController : Controller
    {
        private readonly IUnitofWork _UnitofWork;
        public CatagoryController(IUnitofWork db)
        {
            _UnitofWork = db;
        }
        public IActionResult Index()
        {
            var obejctCatagoryList = _UnitofWork.Catagory.GetAll().ToList();
            return View(obejctCatagoryList);
        }
        public IActionResult Create()
        {

            return View();
        }
        [HttpPost]
        public IActionResult Create(Catagory obj)
        {
            //if (obj.Name == obj.DisplayOrder.ToString())
            //{
            //    ModelState.AddModelError("Name", "Name and Display Order Cant be same");
            //}
            if (ModelState.IsValid)
            {
                _UnitofWork.Catagory.Add(obj);
                _UnitofWork.Save();
                //var obejctCatagoryList = _db.Catagories.ToList();
                //return View("Index", obejctCatagoryList);
                TempData["success"] = "Catagory Successfully Created";
                return RedirectToAction("Index");
            }
            return View();
        }
        public IActionResult Edit(int? id)
        {
            //Catagory obj=_db.Catagories.Find(Id);
            //Catagory obj=_db.Catagories.FirstOrDefault(x => x.Id == Id);
            if (id == 0 || id == null)
            {
                return NotFound();
            }
            Catagory? obj = _UnitofWork.Catagory.Get(x => x.Id == id);
            if (obj == null)
            {
                return NotFound();
            }
            return View(obj);
        }
        [HttpPost]
        public IActionResult Edit(Catagory obj)
        {

            if (ModelState.IsValid)
            {
                _UnitofWork.Catagory.Update(obj);
                _UnitofWork.Save();
                //var obejctCatagoryList = _db.Catagories.ToList();
                //return View("Index", obejctCatagoryList);
                TempData["success"] = "Catagory Successfully Updated";
                return RedirectToAction("Index");
            }
            return View();
        }


        public IActionResult Delete(int? id)
        {
            //Catagory obj=_db.Catagories.Find(Id);
            //Catagory obj=_db.Catagories.FirstOrDefault(x => x.Id == Id);
            if (id == 0 || id == null)
            {
                return NotFound();
            }
            Catagory? obj = _UnitofWork.Catagory.Get(x => x.Id == id);
            if (obj == null)
            {
                return NotFound();
            }
            return View(obj);
        }
        [HttpPost, ActionName("Delete")]
        public IActionResult DeleteCatagory(int? id)
        {
            if (id == 0 || id == null)
            {
                return NotFound();
            }
            Catagory? obj = _UnitofWork.Catagory.Get(x => x.Id == id);
            if (obj == null)
            {
                return NotFound();
            }

            TempData["success"] = "Catagory Successfully Deleted";
            _UnitofWork.Catagory.Remove(obj);
            _UnitofWork.Save();

            return RedirectToAction("Index");
        }
    }

}
