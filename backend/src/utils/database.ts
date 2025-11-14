import { getDbPool } from '@/instances/database';
import { IRecordSet, IResult } from 'mssql';

export enum ExpectedReturn {
  Single,
  Multi,
  None,
}

/**
 * @summary
 * Executes a stored procedure against the database.
 *
 * @param routine The name of the stored procedure to execute (e.g., '[schema].[spName]').
 * @param parameters An object containing the parameters for the stored procedure.
 * @param expectedReturn The expected return type from the procedure.
 * @returns The result from the database, formatted based on expectedReturn.
 */
export async function dbRequest(
  routine: string,
  parameters: object,
  expectedReturn: ExpectedReturn
): Promise<any> {
  try {
    const pool = await getDbPool();
    const request = pool.request();

    for (const [key, value] of Object.entries(parameters)) {
      request.input(key, value);
    }

    const result: IResult<any> = await request.execute(routine);

    switch (expectedReturn) {
      case ExpectedReturn.Single:
        return result.recordset && result.recordset.length > 0 ? result.recordset[0] : null;
      case ExpectedReturn.Multi:
        return result.recordsets;
      case ExpectedReturn.None:
        return;
      default:
        throw new Error('Invalid ExpectedReturn type');
    }
  } catch (error) {
    console.error(`Database request failed for routine: ${routine}`, { parameters, error });
    // Re-throw the error to be handled by the calling service/controller
    throw error;
  }
}
