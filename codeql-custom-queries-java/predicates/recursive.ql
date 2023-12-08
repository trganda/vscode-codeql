/**
 * @name predicates query
 * @description a predicates query for start
 * @kind problem
 * @problem.severity warning
 * @id java/predicates
 */

string getANeighbor(string country) {
  country = "France" and result = "Belgium"
  or
  country = "France" and result = "Germany"
  or
  country = "Germany" and result = "Austria"
  or
  country = "Germany" and result = "Belgium"
  or
  country = getANeighbor(result)
}

from string country
where country = "France"
select getANeighbor(country)