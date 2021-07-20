import UIKit
import CoreData

class ToDoViewController: UITableViewController{    var todos = [Todo]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category? {
        didSet{
            loadTodosFromDevice()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - DataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = todos[indexPath.row].title
        cell.accessoryType = todos[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        todos[indexPath.row].done = !todos[indexPath.row].done
//        context.delete(todos[indexPathpersistentContainer)
        saveTodosIntoDevice()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - ToDoController related methods
    
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new ToDo", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if textField.text != "" {
                let todo = Todo(context: self.context)
                todo.title = textField.text!
                todo.done = false
                todo.category = self.selectedCategory
                self.todos.append(todo)
                self.saveTodosIntoDevice()
            }
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Insert your ToDo here"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Persistent container methods
    
    func saveTodosIntoDevice(){
        do{
            try context.save()
            tableView.reloadData()
        } catch{
            print(error)
        }
    }
    
    func loadTodosFromDevice(from request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "category.name MATCHES %@", selectedCategory!.name!)
        if let additionalPredicate = predicate{
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                categoryPredicate,
                additionalPredicate
            ])
            request.predicate = compoundPredicate
        } else{
            request.predicate = categoryPredicate
        }
        do{
            todos = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}


extension ToDoViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Todo> = Todo.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadTodosFromDevice(from: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadTodosFromDevice()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}

