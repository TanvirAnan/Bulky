using Bulkyweb.Data;
using Bulkyweb.Models;
using Microsoft.AspNetCore.Mvc;

namespace Bulkyweb.Controllers
{
    public class CatagoryController : Controller
    {
        private readonly ApplicationDbContext _db;
        public CatagoryController(ApplicationDbContext db)
        {
            _db = db;
        }
        public IActionResult Index()
        {
            var obejctCatagoryList = _db.Catagories.ToList();
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
                _db.Catagories.Add(obj);
                _db.SaveChanges();
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
            Catagory ? obj = _db.Catagories.Where(x => x.Id == id).FirstOrDefault();
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
                _db.Catagories.Update(obj);
                _db.SaveChanges();
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
            Catagory? obj = _db.Catagories.Where(x => x.Id == id).FirstOrDefault();
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
            Catagory? obj = _db.Catagories.Where(x => x.Id == id).FirstOrDefault();
            if (obj == null)
            {
                return NotFound();
            }

            TempData["success"] = "Catagory Successfully Deleted";
            _db.Catagories.Remove(obj);
            _db.SaveChanges();

            return RedirectToAction("Index");
        }
    }

}
