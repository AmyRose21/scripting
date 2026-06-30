#if defined _pure_ac130_infected_manager_included
 #endinput
#endif
#define _pure_ac130_infected_manager_included

enum struct InfectedManager
{
    StringMap infecteds;

    void Init()
    {
        this.infecteds = new StringMap();
    }

    void Store(int entity)
    {
        char num[8];
        Format(num, 8, "%d", entity);
        if(this.infecteds.ContainsKey(num))
            return;
        
        this.infecteds.SetValue(num, 1);
    }

    void Remove(int entity)
    {
        char num[8];
        Format(num, 8, "%d", entity);
        if(!this.infecteds.ContainsKey(num))
            return;
        
        this.infecteds.Remove(num);
    }

    ArrayList GetAllInfecteds()
    {
        ArrayList arr = new ArrayList();
        StringMapSnapshot shots = this.infecteds.Snapshot();
        char num[8];
        for(int i = 0; i < shots.Length; i++)
        {
            shots.GetKey(i, num, 8);

            int entity = StringToInt(num);

            if(entity <= 0 || !IsValidEntity(entity))
            {
                this.Remove(entity);
                continue;
            }

            if(IsCommonInfected(entity) || IsInfected(entity))
            {
                int curHp = GetEntProp(entity, Prop_Data, "m_iHealth");
                if(curHp <= 0)
                {
                    this.Remove(entity);
                    continue;
                }
                arr.Push(entity);
            }
            else
            {
                this.Remove(entity);
            }
        }
        CloseHandle(shots);

        return arr;
    }

    void Clear()
    {
        this.infecteds.Clear();
    }

}