using BulkyBook.DataAccess.Data;
using BulkyBook.DataAccess.Repository.IRepository;
using BulkyBook.Model;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace BulkyBookweb.Controllers
{
    public class CatagoryController : Controller
    {
        private readonly ICatagoryRepository _CatagoryRepo;
        public CatagoryController(ICatagoryRepository db)
        {
            _CatagoryRepo = db;
        }
        public IActionResult Index()
        {
            var obejctCatagoryList = _CatagoryRepo.GetAll().ToList();
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
                _CatagoryRepo.Add(obj);
                _CatagoryRepo.Save();
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
            Catagory ? obj = _CatagoryRepo.Get(x => x.Id == id);
            if (obj == null) { 
                return NotFound();
            }
            return View(obj);
        }
        [HttpPost]
        public IActionResult Edit(Catagory obj)
        {
           
            if (ModelState.IsValid)
            {
                _CatagoryRepo.Update(obj);
                _CatagoryRepo.Save();
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
            Catagory? obj = _CatagoryRepo.Get(x => x.Id == id);
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
            Catagory? obj = _CatagoryRepo.Get(x => x.Id == id);
            if (obj == null)
            {
                return NotFound();
            }

            TempData["success"] = "Catagory Successfully Deleted";
            _CatagoryRepo.Remove(obj);
            _CatagoryRepo.Save();

            return RedirectToAction("Index");
        }
    }

}
